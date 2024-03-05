require 'spec_helper'

RSpec.describe Magic::Game, "combat -- infect no blockers" do
  include_context "two player game"

  let!(:flensermite) { ResolvePermanent("Flensermite", owner: p1) }

  before do
    game.battlefield.add(flensermite)
  end

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "p1 attacks with Flensermite" do
      p1_starting_life = p1.life
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        flensermite,
        target: p2,
      )

      go_to_combat_damage!

      expect(p2.life).to eq(p2_starting_life)
      expect(p2.counters.of_type(Magic::Counters::Poison).count).to eq(1)
    end
  end
end
