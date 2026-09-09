require "spec_helper"

RSpec.describe Magic::Cards::EumidianWastewaker do
  include_context "two player game"

  it "is an Insect Cleric" do
    expect(ResolvePermanent("Eumidian Wastewaker", owner: p1)).to be_creature
  end
end