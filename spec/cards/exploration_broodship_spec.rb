require "spec_helper"

RSpec.describe Magic::Cards::ExplorationBroodship do
  include_context "two player game"

  it "is an artifact" do
    expect(ResolvePermanent("Exploration Broodship", owner: p1)).to be_artifact
  end
end