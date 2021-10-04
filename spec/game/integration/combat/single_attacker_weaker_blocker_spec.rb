require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, weaker blocker" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:odric) { Card("Odric, Lunarch Marshal") }
  let(:wood_elves) { Card("Wood Elves") }

  before do
    game.battlefield.add(odric)
    game.battlefield.add(wood_elves)
  end

  context "when in combat" do
    before do
      subject.go_to_beginning_of_combat!
    end

    it "p2 blocks with a wood elves" do
      expect(subject.battlefield.cards).to include(odric)
      expect(subject.battlefield.cards).to include(wood_elves)
      p2_starting_life = p2.life

      expect(subject).to be_at_step(:beginning_of_combat)

      subject.next_step
      expect(subject).to be_at_step(:declare_attackers)

      subject.declare_attacker(
        odric,
        target: p2,
      )

      subject.next_step
      expect(subject).to be_at_step(:declare_blockers)

      subject.declare_blocker(
        wood_elves,
        attacker: odric,
      )

      subject.next_step
      expect(subject).to be_at_step(:first_strike)

      subject.next_step
      expect(subject).to be_at_step(:combat_damage)
      expect(odric.zone).to be_battlefield

      expect(wood_elves.zone).to be_graveyard

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
