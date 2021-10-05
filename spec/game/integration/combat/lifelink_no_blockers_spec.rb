require 'spec_helper'

RSpec.describe Magic::Game, "combat -- life linker no blockers" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:basris_acolyte) { Card("Basri's Acolyte", controller: p1) }

  before do
    game.battlefield.add(basris_acolyte)
  end

  context "when in combat" do
    before do
      game.go_to_beginning_of_combat!
    end

    let(:combat) { game.combat }

    it "p1 attacks with Basri's Acolyte" do
      p1_starting_life = p1.life
      p2_starting_life = p2.life

      expect(game).to be_at_step(:beginning_of_combat)

      game.next_step
      expect(game).to be_at_step(:declare_attackers)

      combat.declare_attacker(
        basris_acolyte,
        target: p2,
      )

      game.next_step
      expect(game).to be_at_step(:declare_blockers)

      game.next_step
      expect(game).to be_at_step(:first_strike)

      game.next_step
      expect(game).to be_at_step(:combat_damage)


      expect(p1.life).to eq(p1_starting_life + 2)
      expect(p2.life).to eq(p2_starting_life - 2)
    end
  end
end
