require "spec_helper"

RSpec.describe Magic::Cards::OnduSpiritdancer do
  include_context "two player game"

  it "copies the first enchantment that enters each turn" do
    ResolvePermanent("Ondu Spiritdancer", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(p1.creatures.by_name("Spirited Companion").count).to eq(2)
  end
end