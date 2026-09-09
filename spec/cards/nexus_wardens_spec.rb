require "spec_helper"

RSpec.describe Magic::Cards::NexusWardens do
  include_context "two player game"

  it "gains 2 life when an enchantment enters under your control" do
    ResolvePermanent("Nexus Wardens", owner: p1)
    ResolvePermanent("Spirited Companion", owner: p1)

    expect(p1.life).to eq(22)
  end
end