require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, weaker blocker" do
  include_context "two player game"

  let!(:odric) { ResolvePermanent("Odric, Lunarch Marshal", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves",owner: p2) }
  let!(:vastwood_gorger) { ResolvePermanent("Vastwood Gorger", owner: p2) }

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "p2 blocks with a wood elves and vastwood gorger" do
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        odric,
        target: p2,
      )

      current_turn.attackers_declared!

      current_turn.declare_blocker(
        wood_elves,
        attacker: odric,
      )

      current_turn.declare_blocker(
        vastwood_gorger,
        attacker: odric,
      )

      go_to_combat_damage!

      aggregate_failures do
        expect(odric).to be_dead
        expect(wood_elves).to be_dead
        expect(vastwood_gorger.zone).to be_battlefield
        expect(vastwood_gorger.damage).to eq(2)
      end

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
