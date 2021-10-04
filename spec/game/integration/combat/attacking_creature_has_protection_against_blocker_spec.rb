require 'spec_helper'

RSpec.describe Magic::Game, "combat -- attacking creature has protection against blocker" do
  let(:game) { Magic::Game.new }
  subject(:combat) { Magic::Game::CombatPhase.new(game: game) }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:baneslayer_angel) { Card("Baneslayer Angel", controller: p1) }
  let(:hellkite_punisher) { Card("Hellkite Punisher", controller: p2) }

  before do
    game.battlefield.add(baneslayer_angel)
    game.battlefield.add(hellkite_punisher)
  end

  context "when in combat" do
    before do
      game.go_to_beginning_of_combat!
    end

    it "p2 cannot block with its hellkite" do
      expect(game.battlefield.cards).to include(baneslayer_angel)
      expect(game.battlefield.cards).to include(hellkite_punisher)
      p1_starting_life = p1.life
      p2_starting_life = p2.life

      expect(game).to be_at_step(:beginning_of_combat)

      expect(combat).to be_at_step(:beginning_of_combat)
      combat.next_step
      expect(combat).to be_at_step(:declare_attackers)

      combat.declare_attacker(
        baneslayer_angel,
        target: p2,
      )

      combat.next_step
      expect(combat).to be_at_step(:declare_blockers)

      expect(combat.can_block?(attacker: baneslayer_angel, blocker: hellkite_punisher)).to eq(false)

      expect do
        combat.declare_blocker(
          hellkite_punisher,
          attacker: baneslayer_angel,
        )
      end.to raise_error(Magic::Game::CombatPhase::AttackerHasProtection)

      combat.next_step
      expect(combat).to be_at_step(:first_strike)

      combat.next_step
      expect(combat).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - baneslayer_angel.power)
      # p1 gains life, as Baneslayer Angel has lifelink
      expect(p1.life).to eq(p1_starting_life + baneslayer_angel.power)

      combat.next_step
      expect(combat).to be_at_step(:end_of_combat)
    end
  end
end
