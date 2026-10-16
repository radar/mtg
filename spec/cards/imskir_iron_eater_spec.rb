# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ImskirIronEater do
  include_context "two player game"

  def artifacts(count, owner: p1)
    Array.new(count) { ResolvePermanent("Sol Ring", owner: owner) }
  end

  it "is a 5/5 legendary Demon" do
    imskir = ResolvePermanent("Imskir Iron-Eater", owner: p1)

    expect([imskir.power, imskir.toughness]).to eq([5, 5])
    expect(imskir.types.map(&:to_s)).to include("Legendary", "Creature")
    expect(imskir.cmc).to eq(8)
  end

  describe "affinity for artifacts" do
    before { go_to_main_phase! }

    it "costs {1} less for each artifact you control" do
      artifacts(3)
      imskir = Card("Imskir Iron-Eater", owner: p1)
      p1.hand.add(imskir)
      p1.add_mana(colorless: 3, black: 1, red: 1)

      p1.cast(card: imskir) { |a| a.pay_mana(generic: { colorless: 3 }, black: 1, red: 1) }
      game.stack.resolve!

      expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Imskir Iron-Eater")
    end

    it "does not count an opponent's artifacts" do
      artifacts(3, owner: p2)
      imskir = Card("Imskir Iron-Eater", owner: p1)
      p1.hand.add(imskir)
      p1.add_mana(colorless: 3, black: 1, red: 1)

      expect { p1.cast(card: imskir) { |a| a.pay_mana(generic: { colorless: 3 }, black: 1, red: 1) } }
        .to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end

  describe "enters trigger" do
    def draws_and_loses_for(count)
      artifacts(count)
      hand = p1.hand.count
      life = p1.life
      ResolvePermanent("Imskir Iron-Eater", owner: p1)
      [p1.hand.count - hand, life - p1.life]
    end

    it "draws and loses half the artifacts you control, rounded down (even)" do
      expect(draws_and_loses_for(4)).to eq([2, 2])
    end

    it "rounds down (odd)" do
      expect(draws_and_loses_for(3)).to eq([1, 1])
    end

    it "does nothing with fewer than two artifacts" do
      expect(draws_and_loses_for(1)).to eq([0, 0])
    end

    it "ignores the opponent's artifacts" do
      artifacts(4, owner: p2)

      expect(draws_and_loses_for(0)).to eq([0, 0])
    end
  end

  describe "{3}{R}, sacrifice an artifact" do
    let!(:imskir) { ResolvePermanent("Imskir Iron-Eater", owner: p1) }
    let!(:stone) { ResolvePermanent("Mind Stone", owner: p1) }

    def activate!(who: p1, target:, sacrifice: stone)
      who.add_mana(red: 1, colorless: 3)
      who.activate_ability(ability: imskir.activated_abilities.first) do |a|
        a.pay_mana(generic: { colorless: 3 }, red: 1)
        a.pay_sacrifice(sacrifice)
        a.targeting(target)
      end
      game.stack.resolve!
      game.settle!
    end

    it "deals damage equal to the sacrificed artifact's mana value to a player" do
      expect { activate!(target: p2) }.to change(p2, :life).by(-2)
      expect(game.battlefield.permanents).not_to include(stone)
    end

    it "can target a creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      activate!(target: bears)

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "uses the mana value of whichever artifact is sacrificed" do
      ring = ResolvePermanent("Sol Ring", owner: p1)

      expect { activate!(target: p2, sacrifice: ring) }.to change(p2, :life).by(-1)
    end

    it "only offers artifacts you control to sacrifice" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Sol Ring", owner: p2)
      choices = imskir.activated_abilities.first.costs.last.choices.to_a

      expect(choices).to contain_exactly(stone)
      expect(choices).not_to include(bears, theirs)
    end

    it "cannot be activated by an opponent" do
      expect { activate!(who: p2, target: p1) }.to raise_error(Magic::IllegalAction)

      expect(game.battlefield.permanents).to include(stone)
      expect(p2.mana_pool[:red]).to eq(1)
      expect(p2.mana_pool[:colorless]).to eq(3)
    end
  end
end
