require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker with vigilance, no blockers" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:alpine_watchdog) { Card("Alpine Watchdog") }

  before do
    game.battlefield.add(alpine_watchdog)
  end

  context "when in combat" do
    before do
      subject.go_to_beginning_of_combat!
    end

    it "p1 deals damage to p2" do
      p2_starting_life = p2.life

      expect(subject).to be_at_step(:beginning_of_combat)

      subject.next_step
      expect(subject).to be_at_step(:declare_attackers)

      subject.declare_attacker(
        alpine_watchdog,
        target: p2,
      )

      subject.next_step
      expect(subject).to be_at_step(:declare_blockers)

      subject.next_step
      expect(subject).to be_at_step(:first_strike)

      subject.next_step
      expect(subject).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 2)
      expect(alpine_watchdog).not_to be_tapped
    end
  end
end
