# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DemonicEmbrace do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_from_hand(creature)
    card = Card("Demonic Embrace", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 2).targeting(creature) }
    game.stack.resolve!
    game.settle!
    card
  end

  it "gives the enchanted creature +3/+1, flying and the Demon type" do
    cast_from_hand(bears)

    expect([bears.power, bears.toughness]).to eq([5, 3])
    expect(bears).to be_flying
    expect(bears.type?("Demon")).to eq(true)
    expect(bears.type?("Bear")).to eq(true)
  end

  context "in the graveyard" do
    let(:embrace) { Card("Demonic Embrace", owner: p1) }
    let(:fodder) { Card("Forest", owner: p1) }

    before do
      p1.graveyard.add(embrace)
      p1.hand.add(fodder)
      p1.add_mana(black: 3)
    end

    def cast_from_graveyard(discard: fodder, pay_life: true)
      p1.cast(card: embrace) do |a|
        a.pay_mana(generic: { black: 1 }, black: 2)
        a.pay_additional_life if pay_life
        a.pay_discard(discard) if discard
        a.targeting(bears)
      end
      game.stack.resolve!
      game.settle!
    end

    it "can be cast by paying 3 life and discarding a card as well" do
      cast_from_graveyard

      expect(embrace.zone).to be_battlefield
      expect(p1.life).to eq(17)
      expect(fodder.zone).to be_graveyard
      expect([bears.power, bears.toughness]).to eq([5, 3])
    end

    it "can't be cast without paying the life" do
      expect { cast_from_graveyard(pay_life: false) }.to raise_error("Additional costs have not been paid")
    end

    it "can't be cast without discarding a card" do
      expect { cast_from_graveyard(discard: nil) }.to raise_error("Additional costs have not been paid")
    end
  end

  it "can't be cast from the graveyard of another player" do
    embrace = Card("Demonic Embrace", owner: p2)
    p2.graveyard.add(embrace)

    expect(embrace.additional_costs.count).to eq(2) # the costs follow the card, the permission is checked on cast
  end
end
