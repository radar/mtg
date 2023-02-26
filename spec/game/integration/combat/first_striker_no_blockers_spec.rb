require 'spec_helper'

RSpec.describe Magic::Game, "combat -- first striker, no blockers" do
  include_context "two player game"

  let!(:battlefield_raptor) { ResolvePermanent("Battlefield Raptor", owner: p1) }

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "p1 attacks with battlefield raptor" do
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        battlefield_raptor,
        target: p2,
      )

      go_to_combat_damage!

      expect(p2.life).to eq(p2_starting_life - 1)
    end
  end
end
