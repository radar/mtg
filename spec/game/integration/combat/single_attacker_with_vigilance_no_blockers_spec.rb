require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker with vigilance, no blockers" do
  include_context "two player game"

  let(:alpine_watchdog) { Card("Alpine Watchdog") }

  before do
    game.battlefield.add(alpine_watchdog)
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
        alpine_watchdog,
        target: p2,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_blockers)

      current_turn.next_step
      expect(current_turn).to be_at_step(:first_strike)

      current_turn.next_step
      expect(current_turn).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 2)
      expect(alpine_watchdog).not_to be_tapped
    end
  end
end
