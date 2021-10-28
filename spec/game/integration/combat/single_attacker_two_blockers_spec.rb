require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, weaker blocker" do
  include_context "two player game"

  let(:odric) { Card("Odric, Lunarch Marshal") }
  let(:wood_elves) { Card("Wood Elves") }
  let(:vastwood_gorger) { Card("Vastwood Gorger") }

  before do
    game.battlefield.add(odric)
    game.battlefield.add(wood_elves)
    game.battlefield.add(vastwood_gorger)
  end

  context "when in combat" do
    before do
      current_turn.go_to_beginning_of_combat!
    end

    it "p2 blocks with a wood elves and vastwood gorger" do
      expect(game.battlefield.cards).to include(odric)
      expect(game.battlefield.cards).to include(wood_elves)
      expect(game.battlefield.cards).to include(vastwood_gorger)
      p2_starting_life = p2.life

      expect(current_turn).to be_at_step(:beginning_of_combat)

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_attackers)

      current_turn.declare_attacker(
        odric,
        target: p2,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_blockers)

      current_turn.declare_blocker(
        wood_elves,
        attacker: odric,
      )

      current_turn.declare_blocker(
        vastwood_gorger,
        attacker: odric,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:first_strike)

      current_turn.next_step
      expect(current_turn).to be_at_step(:combat_damage)
      expect(odric.zone).to be_graveyard
      expect(wood_elves.zone).to be_graveyard
      expect(vastwood_gorger.zone).to be_battlefield
      expect(vastwood_gorger.damage).to eq(2)

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
