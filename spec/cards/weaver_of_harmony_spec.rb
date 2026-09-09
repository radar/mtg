require "spec_helper"

RSpec.describe Magic::Cards::WeaverOfHarmony do
  include_context "two player game"

  it "boosts other enchantment creatures" do
    ResolvePermanent("Weaver of Harmony", owner: p1)
    companion = ResolvePermanent("Spirited Companion", owner: p1)
    game.tick!

    expect(companion.power).to eq(2)
    expect(companion.toughness).to eq(2)
  end
end