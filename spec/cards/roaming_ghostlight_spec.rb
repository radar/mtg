require 'spec_helper'

RSpec.describe Magic::Cards::RoamingGhostlight do
  include_context "two player game"

  before do
    ResolvePermanent("Wood Elves", owner: p2) # Non-spirit creature
    ResolvePermanent("Wandering Ones", owner: p2) # Spirit creature
  end

  context "when it enters the battlefield" do
    it "returns non-Spirit creature to its owner's hand" do
      ResolvePermanent("Roaming Ghostlight", owner: p1)

      # Choice is automatic given there's only one correct choice
      expect(p2.hand.by_name("Wood Elves").count).to eq(1)

      expect(game.battlefield.creatures.by_name("Wandering Ones").count).to eq(1)
      expect(p2.hand.by_name("Wandering Ones").count).to eq(0)
    end
  end
end
