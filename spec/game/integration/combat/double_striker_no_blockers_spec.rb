require 'spec_helper'

RSpec.describe Magic::Game, "combat -- double striker, no blockers" do
  include_context "two player game"

  let!(:fencing_ace) { ResolvePermanent("Fencing Ace", controller: p1) }

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "p1 attacks with fencing ace" do
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        fencing_ace,
        target: p2,
      )

      current_turn.attackers_declared!
      current_turn.combat_damage!
      expect(p2.life).to eq(p2_starting_life - fencing_ace.power * 2)

    end
  end
end
