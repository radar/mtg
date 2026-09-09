require "spec_helper"

RSpec.describe Magic::Cards::StarfieldOfNyx do
  include_context "two player game"

  it "is an enchantment" do
    expect(ResolvePermanent("Starfield of Nyx", owner: p1)).to be_enchantment
  end
end