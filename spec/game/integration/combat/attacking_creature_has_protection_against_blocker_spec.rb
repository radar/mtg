require 'spec_helper'

RSpec.describe Magic::Game, "combat -- attacking creature has protection against blocker" do
  include_context "two player game"

  let(:baneslayer_angel) { Card("Baneslayer Angel", controller: p1) }
  let(:hellkite_punisher) { Card("Hellkite Punisher", controller: p2) }

  before do
    game.battlefield.add(baneslayer_angel)
    game.battlefield.add(hellkite_punisher)
  end

  context "when in combat" do
    before do
      current_turn.go_to_beginning_of_combat!
    end

    it "p2 cannot block with its hellkite" do
      expect(game.battlefield.cards).to include(baneslayer_angel)
      expect(game.battlefield.cards).to include(hellkite_punisher)
      p1_starting_life = p1.life
      p2_starting_life = p2.life

      expect(current_turn).to be_at_step(:beginning_of_combat)

      expect(current_turn).to be_at_step(:beginning_of_combat)
      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_attackers)

      current_turn.declare_attacker(
        baneslayer_angel,
        target: p2,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_blockers)

      expect(current_turn.can_block?(attacker: baneslayer_angel, blocker: hellkite_punisher)).to eq(false)

      expect do
        current_turn.declare_blocker(
          hellkite_punisher,
          attacker: baneslayer_angel,
        )
      end.to raise_error(Magic::Game::CombatPhase::AttackerHasProtection)

      current_turn.next_step
      expect(current_turn).to be_at_step(:first_strike)

      current_turn.next_step
      expect(current_turn).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - baneslayer_angel.power)
      # p1 gains life, as Baneslayer Angel has lifelink
      expect(p1.life).to eq(p1_starting_life + baneslayer_angel.power)

      current_turn.next_step
      expect(current_turn).to be_at_step(:end_of_combat)
    end
  end
end
