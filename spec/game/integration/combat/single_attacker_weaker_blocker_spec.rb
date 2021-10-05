require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, weaker blocker" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:odric) { Card("Odric, Lunarch Marshal") }
  let(:wood_elves) { Card("Wood Elves") }

  before do
    game.battlefield.add(odric)
    game.battlefield.add(wood_elves)
  end

  context "when in combat" do
    before do
      game.go_to_beginning_of_combat!
    end

    let(:combat) { game.combat }

    it "p2 blocks with a wood elves" do
      expect(game.battlefield.cards).to include(odric)
      expect(game.battlefield.cards).to include(wood_elves)
      p2_starting_life = p2.life

      expect(game).to be_at_step(:beginning_of_combat)

      game.next_step
      expect(game).to be_at_step(:declare_attackers)

      combat.declare_attacker(
        odric,
        target: p2,
      )

      game.next_step
      expect(game).to be_at_step(:declare_blockers)

      combat.declare_blocker(
        wood_elves,
        attacker: odric,
      )

      game.next_step
      expect(game).to be_at_step(:first_strike)

      game.next_step
      expect(game).to be_at_step(:combat_damage)
      expect(odric.zone).to be_battlefield

      expect(wood_elves.zone).to be_graveyard

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
