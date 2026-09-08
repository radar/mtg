require "spec_helper"

RSpec.describe Magic::Cards::SpiritedCompanion do
  include_context "two player game"

  it "draws a card when it enters" do
    hand_size = p1.hand.count
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "is an enchantment creature Dog" do
    companion = ResolvePermanent("Spirited Companion", owner: p1)

    expect(companion).to be_creature
    expect(companion).to be_enchantment
    expect(companion.any_type?("Dog")).to be(true)
  end
end