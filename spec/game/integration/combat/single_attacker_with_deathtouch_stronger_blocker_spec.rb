require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker with deathtouch, stronger blocker" do
  include_context "two player game"

  let(:acidic_slime) { Card("Acidic Slime") }
  let(:vastwood_gorger) { Card("Vastwood Gorger") }

  before do
    game.battlefield.add(acidic_slime)
    game.battlefield.add(vastwood_gorger)
  end

  context "when in combat" do
    before do
      current_turn.go_to_beginning_of_combat!
    end

    it "p2 blocks with a vastwood gorger" do
      expect(game.battlefield.cards).to include(acidic_slime)
      expect(game.battlefield.cards).to include(vastwood_gorger)
      p2_starting_life = p2.life

      expect(current_turn).to be_at_step(:beginning_of_combat)

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_attackers)

      current_turn.declare_attacker(
        acidic_slime,
        target: p2,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_blockers)

      current_turn.declare_blocker(
        vastwood_gorger,
        attacker: acidic_slime,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:first_strike)

      current_turn.next_step
      expect(current_turn).to be_at_step(:combat_damage)
      expect(acidic_slime.zone).to be_graveyard
      expect(game.battlefield.cards).not_to include(acidic_slime)

      expect(vastwood_gorger.zone).to be_graveyard
      expect(game.battlefield.cards).not_to include(vastwood_gorger)

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
