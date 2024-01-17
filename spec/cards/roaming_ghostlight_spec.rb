require 'spec_helper'

RSpec.describe Magic::Cards::RoamingGhostlight do
  include_context "two player game"

  before do
    ResolvePermanent("Wood Elves", owner: p2)
  end

  context "when it enters the battlefield" do
    it "returns non-Spirit creature to its owner's hand" do
      ResolvePermanent("Roaming Ghostlight", owner: p1)

      expect(p2.hand.by_name("Wood Elves").count).to eq(1)
    end
  end
end
