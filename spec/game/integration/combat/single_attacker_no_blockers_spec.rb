require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, no blockers" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer") }

  before do
    game.battlefield.add(loxodon_wayfarer)
  end

  it "p1 deals damage to p2" do
    p2_starting_life = p2.life

    expect(combat).to be_at_step(:beginning_of_combat)

    combat.next_step
    expect(combat).to be_at_step(:declare_attackers)

    combat.declare_attacker(
      loxodon_wayfarer,
      target: p2,
    )

    combat.next_step
    expect(combat).to be_at_step(:declare_blockers)

    combat.next_step
    expect(combat).to be_at_step(:first_strike)

    combat.next_step
    expect(combat).to be_at_step(:combat_damage)

    expect(p2.life).to eq(p2_starting_life - 1)
    expect(loxodon_wayfarer).to be_tapped
  end
end
