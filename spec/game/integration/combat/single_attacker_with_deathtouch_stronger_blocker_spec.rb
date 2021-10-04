require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker with deathtouch, stronger blocker" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:acidic_slime) { Card("Acidic Slime") }
  let(:vastwood_gorger) { Card("Vastwood Gorger") }

  before do
    game.battlefield.add(acidic_slime)
    game.battlefield.add(vastwood_gorger)
  end

  it "p2 blocks with a vastwood gorger" do
    expect(game.battlefield.cards).to include(acidic_slime)
    expect(game.battlefield.cards).to include(vastwood_gorger)
    p2_starting_life = p2.life

    expect(combat).to be_at_step(:beginning_of_combat)

    combat.next_step
    expect(combat).to be_at_step(:declare_attackers)

    combat.declare_attacker(
      acidic_slime,
      target: p2,
    )

    combat.next_step
    expect(combat).to be_at_step(:declare_blockers)

    combat.declare_blocker(
      vastwood_gorger,
      attacker: acidic_slime,
    )

    combat.next_step
    expect(combat).to be_at_step(:first_strike)

    combat.next_step
    expect(combat).to be_at_step(:combat_damage)
    expect(acidic_slime.zone).to be_graveyard
    expect(game.battlefield.cards).not_to include(acidic_slime)

    expect(vastwood_gorger.zone).to be_graveyard
    expect(game.battlefield.cards).not_to include(vastwood_gorger)

    expect(p2.life).to eq(p2_starting_life)
  end
end
