require 'spec_helper'

RSpec.describe Magic::Game, "combat -- double striker, no blockers" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:fencing_ace) { Card("Fencing Ace") }

  before do
    game.battlefield.add(fencing_ace)
  end

  context "when in combat" do
    it "p1 attacks with fencing ace" do
      p2_starting_life = p2.life

      expect(combat).to be_at_step(:beginning_of_combat)

      subject.next_step
      expect(combat).to be_at_step(:declare_attackers)

      combat.declare_attacker(
        fencing_ace,
        target: p2,
      )

      combat.next_step
      expect(combat).to be_at_step(:declare_blockers)

      combat.next_step
      expect(combat).to be_at_step(:first_strike)

      combat.next_step
      expect(combat).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 2)
    end
  end
end
