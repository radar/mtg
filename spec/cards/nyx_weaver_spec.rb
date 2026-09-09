require "spec_helper"

RSpec.describe Magic::Cards::NyxWeaver do
  include_context "two player game"

  it "has reach and is an enchantment creature" do
    weaver = ResolvePermanent("Nyx Weaver", owner: p1)

    expect(weaver).to be_enchantment
    expect(weaver).to be_creature
    expect(weaver).to be_reach
  end
end