require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, one blocker" do
  include_context "two player game"

  let(:colossal_dreadmaw) { Card("Colossal Dreadmaw") }
  let(:wood_elves) { Card("Wood Elves") }

  before do
    game.battlefield.add(colossal_dreadmaw)
    game.battlefield.add(wood_elves)
  end

  context "when in combat" do
    before do
      game.current_turn.go_to_beginning_of_combat!
    end

    it "p1 deals damage to p2" do
      p2_starting_life = p2.life

      expect(current_turn).to be_at_step(:beginning_of_combat)

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_attackers)

      current_turn.declare_attacker(
        colossal_dreadmaw,
        target: p2,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_blockers)

      current_turn.declare_blocker(
        wood_elves,
        attacker: colossal_dreadmaw,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:first_strike)

      current_turn.next_step
      expect(current_turn).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 5)
      expect(wood_elves.zone).to be_graveyard
      expect(colossal_dreadmaw).to be_tapped
    end
  end
end
