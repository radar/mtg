# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Shinestriker do
  include_context "two player game"
  before { go_to_main_phase! }

  it "has flying" do
    expect(ResolvePermanent("Shinestriker", owner: p1).flying?).to eq(true)
  end

  it "draws cards equal to the number of colors among permanents you control" do
    ResolvePermanent("Alaborn Trooper", owner: p1)
    card = Card("Shinestriker", owner: p1)
    p1.hand.add(card)
    p1.add_mana(blue: 6)
    hand_before = p1.hand.count
    cast_and_resolve(card: card, player: p1) { |a| a.pay_mana(generic: { blue: 4 }, blue: 2) }

    # Alaborn Trooper (W) + Shinestriker (U); the cast card left the hand
    expect(p1.hand.count).to eq(hand_before - 1 + 2)
  end
end
