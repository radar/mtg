require 'spec_helper'

RSpec.describe Magic::Game, "combat -- double striker, no blockers" do
  include_context "two player game"

  let(:fencing_ace) { Card("Fencing Ace") }

  before do
    game.battlefield.add(fencing_ace)
  end

  context "when in combat" do
    before do
      current_turn.go_to_beginning_of_combat!
    end

    it "p1 attacks with fencing ace" do
      p2_starting_life = p2.life

      expect(current_turn).to be_at_step(:beginning_of_combat)

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_attackers)

      current_turn.declare_attacker(
        fencing_ace,
        target: p2,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_blockers)

      current_turn.next_step
      expect(current_turn).to be_at_step(:first_strike)

      current_turn.next_step
      expect(current_turn).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 2)
    end
  end
end
