require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, stronger blocker" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer") }
  let(:vastwood_gorger) { Card("Vastwood Gorger") }

  before do
    game.battlefield.add(loxodon_wayfarer)
    game.battlefield.add(vastwood_gorger)
  end

  context "when in combat" do
    before do
      game.go_to_beginning_of_combat!
    end

    let(:combat) { game.combat }

    it "p2 blocks with a vastwood gorger" do
      expect(game.battlefield.cards).to include(loxodon_wayfarer)
      expect(game.battlefield.cards).to include(vastwood_gorger)
      p2_starting_life = p2.life

      expect(game).to be_at_step(:beginning_of_combat)

      game.next_step
      expect(game).to be_at_step(:declare_attackers)

      combat.declare_attacker(
        loxodon_wayfarer,
        target: p2,
      )

      game.next_step
      expect(game).to be_at_step(:declare_blockers)

      combat.declare_blocker(
        vastwood_gorger,
        attacker: loxodon_wayfarer,
      )

      game.next_step
      expect(game).to be_at_step(:first_strike)

      game.next_step
      expect(game).to be_at_step(:combat_damage)
      expect(loxodon_wayfarer.zone).to be_graveyard
      expect(game.battlefield.cards).not_to include(loxodon_wayfarer)

      expect(vastwood_gorger.zone).to be_battlefield
      expect(game.battlefield.cards).to include(vastwood_gorger)

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
