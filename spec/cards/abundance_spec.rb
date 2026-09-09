require "spec_helper"

RSpec.describe Magic::Cards::Abundance do
  include_context "two player game"

  it "is an enchantment" do
    expect(ResolvePermanent("Abundance", owner: p1)).to be_enchantment
  end
end