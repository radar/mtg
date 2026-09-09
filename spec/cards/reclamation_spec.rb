require "spec_helper"

RSpec.describe Magic::Cards::Reclamation do
  include_context "two player game"

  it "is an enchantment" do
    expect(ResolvePermanent("Reclamation", owner: p1)).to be_enchantment
  end
end