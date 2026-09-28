# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Shimmercreep do
  include_context "two player game"
  before { go_to_main_phase! }

  it "has menace" do
    expect(ResolvePermanent("Shimmercreep", owner: p1).menace?).to eq(true)
  end

  it "drains each opponent for the number of colors among permanents you control" do
    ResolvePermanent("Alaborn Trooper", owner: p1)
    card = Card("Shimmercreep", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 5)
    cast_and_resolve(card: card, player: p1) { |a| a.pay_mana(generic: { black: 4 }, black: 1) }

    # Alaborn Trooper (W) + Shimmercreep (B)
    expect(p2.life).to eq(18)
    expect(p1.life).to eq(22)
  end
end
