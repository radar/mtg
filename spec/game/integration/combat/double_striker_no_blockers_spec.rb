require 'spec_helper'

RSpec.describe Magic::Game, "combat -- double striker, no blockers" do
  let(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:fencing_ace) { Card("Fencing Ace") }

  before do
    game.battlefield.add(fencing_ace)
  end

  context "when in combat" do
    before do
      game.go_to_beginning_of_combat!
    end

    it "p1 attacks with fencing ace" do
      p2_starting_life = p2.life

      expect(game).to be_at_step(:beginning_of_combat)
      combat = game.combat

      game.next_step
      expect(game).to be_at_step(:declare_attackers)

      combat.declare_attacker(
        fencing_ace,
        target: p2,
      )

      game.next_step
      expect(game).to be_at_step(:declare_blockers)

      game.next_step
      expect(game).to be_at_step(:first_strike)

      game.next_step
      expect(game).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 2)
    end
  end
end
