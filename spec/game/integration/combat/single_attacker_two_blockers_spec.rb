require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, weaker blocker" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:odric) { Card("Odric, Lunarch Marshal") }
  let(:wood_elves) { Card("Wood Elves") }
  let(:vastwood_gorger) { Card("Vastwood Gorger") }

  before do
    game.battlefield.add(odric)
    game.battlefield.add(wood_elves)
    game.battlefield.add(vastwood_gorger)
  end

  context "when in combat" do
    before do
      subject.step.force_state!(:first_main)
      subject.next_step
    end

    it "p2 blocks with a wood elves and vastwood gorger" do
      expect(subject.battlefield.cards).to include(odric)
      expect(subject.battlefield.cards).to include(wood_elves)
      expect(subject.battlefield.cards).to include(vastwood_gorger)
      p2_starting_life = p2.life

      expect(subject.step).to be_beginning_of_combat

      subject.next_step
      expect(subject.step).to be_declare_attackers

      subject.declare_attacker(
        odric,
        target: p2,
      )

      subject.next_step
      expect(subject.step).to be_declare_blockers

      subject.declare_blocker(
        wood_elves,
        target: odric,
      )

      subject.declare_blocker(
        vastwood_gorger,
        target: odric,
      )

      subject.next_step
      expect(subject.step).to be_first_strike

      subject.next_step
      expect(subject.step).to be_combat_damage
      expect(odric.zone).to be_graveyard
      expect(wood_elves.zone).to be_graveyard
      expect(vastwood_gorger.zone).to be_battlefield
      expect(vastwood_gorger.damage).to eq(2)

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
