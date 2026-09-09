require "spec_helper"

RSpec.describe Magic::Cards::OnduSpiritdancer do
  include_context "two player game"

  it "copies the first enchantment that enters each turn" do
    ResolvePermanent("Ondu Spiritdancer", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(p1.creatures.by_name("Spirited Companion").count).to eq(2)
  end

  it "lets each Spiritdancer copy once per turn" do
    ResolvePermanent("Ondu Spiritdancer", owner: p1)
    ResolvePermanent("Ondu Spiritdancer", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(p1.creatures.by_name("Spirited Companion").count).to eq(3)
  end
end