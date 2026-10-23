# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShilgengarSireOfFamine do
  include_context "two player game"

  let!(:shilgengar) { ResolvePermanent("Shilgengar Sire Of Famine", owner: p1) }

  def blood(player = p1) = player.permanents.select { _1.name == "Blood" }

  def sacrifice!(creature)
    p1.activate_ability(ability: shilgengar.activated_abilities.first) { _1.pay_sacrifice(creature) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 6/6 flyer" do
    expect([shilgengar.power, shilgengar.toughness]).to eq([6, 6])
    expect(shilgengar).to be_flying
  end

  it "makes one Blood token when sacrificing a non-Angel" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    sacrifice!(bears)

    expect(blood.count).to eq(1)
    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "makes Blood tokens equal to the toughness of a sacrificed Angel" do
    angel = ResolvePermanent("Serra Angel", owner: p1)
    sacrifice!(angel)

    expect(blood.count).to eq(4)
  end

  it "cannot sacrifice itself" do
    expect { p1.activate_ability(ability: shilgengar.activated_abilities.first) { _1.pay_sacrifice(shilgengar) } }
      .to raise_error(Magic::Costs::SacrificeAnother::SourceSacrificed)
  end

  context "reanimation ability" do
    def reanimate!(tokens)
      p1.add_mana(black: 3)
      p1.activate_ability(ability: shilgengar.activated_abilities.last) do
        _1.pay_mana(black: 3)
        _1.pay_sacrifice(tokens)
      end
      game.stack.resolve!
      game.settle!
    end

    before do
      6.times { shilgengar.create_token(token: Magic::Tokens::Blood) }
      game.settle!
      Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
      Card("Serra Angel", owner: p1).tap { p1.graveyard.add(_1) }
    end

    it "returns every creature card from the graveyard with a finality counter, as Vampires" do
      reanimate!(blood)

      returned = p1.creatures.reject { _1 == shilgengar }
      expect(returned.map(&:name)).to contain_exactly("Grizzly Bears", "Serra Angel")
      expect(returned).to all(satisfy { _1.type?("Vampire") })
      expect(returned).to all(satisfy { _1.counters.of_type(Magic::Counters["finality"]).count == 1 })
      expect(blood).to be_empty
    end

    it "needs six Blood tokens" do
      blood.last.sacrifice!
      expect { reanimate!(blood) }.to raise_error(Magic::IllegalAction)
    end
  end

  context "Blood token" do
    it "loots: {1}, {T}, discard a card, sacrifice" do
      shilgengar.create_token(token: Magic::Tokens::Blood)
      game.settle!
      token = blood.first
      discard = p1.hand.cards.first
      p1.add_mana(red: 1)
      p1.activate_ability(ability: token.activated_abilities.first) do
        _1.pay_mana(generic: { red: 1 })
        _1.pay_discard(discard)
      end
      game.stack.resolve!

      expect(p1.graveyard.cards).to include(discard)
      expect(blood).to be_empty
    end
  end
end
