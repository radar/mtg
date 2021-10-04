require 'spec_helper'

RSpec.describe Magic::Game, "combat -- attacking creature has protection against blocker" do
  subject(:game) { Magic::Game.new }

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
      subject.go_to_beginning_of_combat!
    end

    it "p2 cannot block with its hellkite" do
      expect(subject.battlefield.cards).to include(baneslayer_angel)
      expect(subject.battlefield.cards).to include(hellkite_punisher)
      p1_starting_life = p1.life
      p2_starting_life = p2.life

      expect(subject).to be_at_step(:beginning_of_combat)

      subject.next_step
      expect(subject).to be_at_step(:declare_attackers)

      subject.declare_attacker(
        baneslayer_angel,
        target: p2,
      )

      subject.next_step
      expect(subject).to be_at_step(:declare_blockers)

      expect(subject.can_block?(attacker: baneslayer_angel, blocker: hellkite_punisher)).to eq(false)

      expect do
        subject.declare_blocker(
          hellkite_punisher,
          attacker: baneslayer_angel,
        )
      end.to raise_error(Magic::Game::CombatPhase::AttackerHasProtection)

      subject.next_step
      expect(subject).to be_at_step(:first_strike)

      subject.next_step
      expect(subject).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - baneslayer_angel.power)
      # p1 gains life, as Baneslayer Angel has lifelink
      expect(p1.life).to eq(p1_starting_life + baneslayer_angel.power)
    end
  end
end
