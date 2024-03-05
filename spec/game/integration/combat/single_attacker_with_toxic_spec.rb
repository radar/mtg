require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker with toxic" do
  include_context "two player game"

  let!(:annex_sentry) { ResolvePermanent("Annex Sentry", owner: p1) }

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "p1 deals damage to p2, adding a poison counter" do
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        annex_sentry,
        target: p2,
      )

      current_turn.attackers_declared!

      go_to_combat_damage!

      aggregate_failures do
        expect(p2.life).to eq(p2_starting_life - 1)
        expect(p2.counters.of_type(Magic::Counters::Poison).count).to eq(1)
      end
    end
  end
end
