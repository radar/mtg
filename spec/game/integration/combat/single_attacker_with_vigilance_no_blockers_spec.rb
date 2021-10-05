require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker with vigilance, no blockers" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:alpine_watchdog) { Card("Alpine Watchdog") }

  before do
    game.battlefield.add(alpine_watchdog)
  end

  context "when in combat" do
    before do
      game.go_to_beginning_of_combat!
    end

    let(:combat) { game.combat }

    it "p1 deals damage to p2" do
      p2_starting_life = p2.life

      expect(game).to be_at_step(:beginning_of_combat)

      game.next_step
      expect(game).to be_at_step(:declare_attackers)

      combat.declare_attacker(
        alpine_watchdog,
        target: p2,
      )

      game.next_step
      expect(game).to be_at_step(:declare_blockers)

      game.next_step
      expect(game).to be_at_step(:first_strike)

      game.next_step
      expect(game).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 2)
      expect(alpine_watchdog).not_to be_tapped
    end
  end
end
