require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, one blocker" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:colossal_dreadmaw) { Card("Colossal Dreadmaw") }
  let(:wood_elves) { Card("Wood Elves") }

  before do
    game.battlefield.add(colossal_dreadmaw)
    game.battlefield.add(wood_elves)
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
        colossal_dreadmaw,
        target: p2,
      )

      game.next_step
      expect(game).to be_at_step(:declare_blockers)

      combat.declare_blocker(
        wood_elves,
        attacker: colossal_dreadmaw,
      )

      game.next_step
      expect(game).to be_at_step(:first_strike)

      game.next_step
      expect(game).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 5)
      expect(wood_elves.zone).to be_graveyard
      expect(colossal_dreadmaw).to be_tapped
    end
  end
end
