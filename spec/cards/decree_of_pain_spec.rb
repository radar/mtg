# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DecreeOfPain do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Decree Of Pain", owner: p1).tap { p1.hand.add(_1) } }

  it "destroys all creatures and draws a card for each one destroyed" do
    3.times { ResolvePermanent("Grizzly Bears", owner: p2) }
    ResolvePermanent("Grizzly Bears", owner: p1)
    hand = p1.hand.cards.count
    p1.add_mana(black: 8)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 6 }, black: 2) }
    game.stack.resolve!
    game.settle!

    expect(game.battlefield.creatures).to be_empty
    expect(p1.hand.cards.count).to eq(hand + 4)
  end

  it "draws nothing with no creatures" do
    hand = p1.hand.cards.count
    p1.add_mana(black: 8)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 6 }, black: 2) }
    game.stack.resolve!

    expect(p1.hand.cards.count).to eq(hand)
  end

  describe "cycling {3}{B}{B}" do
    it "draws a card and gives all creatures -2/-2 until end of turn" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      bigger = ResolvePermanent("Shroudstomper", owner: p2)
      p1.add_mana(black: 5)
      hand = p1.hand.cards.count
      p1.cycle(card: spell) { _1.pay_mana(generic: { black: 3 }, black: 2) }
      game.settle!

      expect(spell.zone).to be_graveyard
      expect(p1.hand.cards.count).to eq(hand + 1) # the card added to hand, discarded, and one drawn
      expect(bears.zone).to be_nil
      expect([bigger.power, bigger.toughness]).to eq([3, 3])
    end
  end
end
