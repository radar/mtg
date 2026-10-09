# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PlunderTheTrollshaws do
  include_context "two player game"

  let(:plunder) { Card("Plunder The Trollshaws", owner: p1) }

  before { p1.hand.add(plunder) }

  it "draws a card when cast from hand" do
    p1.add_mana(blue: 2)
    hand = p1.hand.count
    p1.cast(card: plunder) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand - 1 + 1)
    expect(plunder.zone).to be_graveyard
  end

  it "draws two cards when cast from the graveyard with flashback, then is exiled" do
    p1.add_mana(blue: 2)
    p1.cast(card: plunder) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
    game.stack.resolve!

    p1.add_mana(blue: 4)
    hand = p1.hand.count
    p1.cast(card: plunder, flashback: true) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1) }
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand + 2)
    expect(plunder.zone).to be_exile
  end
end
