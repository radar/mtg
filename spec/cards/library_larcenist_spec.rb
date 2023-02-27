require 'spec_helper'

RSpec.describe Magic::Cards::LibraryLarcenist do
  include_context "two player game"

  subject(:siege_striker) { ResolvePermanent("Library Larcenist", owner: p1) }

  before do
    skip_to_combat!
  end

  context "card draw" do
    it "draws controller one card" do
      current_turn.declare_attackers!

      current_turn.declare_attacker(
        siege_striker,
        target: p2,
      )

      expect(p1).to receive(:draw!)
      current_turn.attackers_declared!
    end
  end
end
