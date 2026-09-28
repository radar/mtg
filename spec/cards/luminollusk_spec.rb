# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Luminollusk do
  include_context "two player game"
  before { go_to_main_phase! }

  it "has deathtouch" do
    expect(ResolvePermanent("Luminollusk", owner: p1).deathtouch?).to eq(true)
  end

  it "gains life equal to the number of colors among permanents you control" do
    ResolvePermanent("Alaborn Trooper", owner: p1)
    card = Card("Luminollusk", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 4)
    cast_and_resolve(card: card, player: p1) { |a| a.pay_mana(generic: { green: 3 }, green: 1) }

    # Alaborn Trooper (W) + Luminollusk (G)
    expect(p1.life).to eq(22)
  end
end
