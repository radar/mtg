require 'spec_helper'

RSpec.describe Magic::Game, "combat" do
  subject(:game) { Magic::Game.new }

  let(:p1) { Magic::Player.new }
  let(:p2) { Magic::Player.new }
  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer") }
  let(:vastwood_gorger) { Card("Vastwood Gorger") }

  before do
    game.add_player(p1)
    game.add_player(p2)
    game.battlefield.add(loxodon_wayfarer)
    game.battlefield.add(vastwood_gorger)
  end

  context "when in combat" do
    before do
      subject.step.force_state!(:first_main)
      subject.next_step
    end

    it "p1 deals damage to p2" do
      p2_starting_life = p2.life

      expect(subject.step).to be_beginning_of_combat

      subject.next_step
      expect(subject.step).to be_declare_attackers

      subject.declare_attacker(
        loxodon_wayfarer,
        target: p2,
      )

      subject.next_step
      expect(subject.step).to be_declare_blockers

      subject.next_step
      expect(subject.step).to be_first_strike

      subject.next_step
      expect(subject.step).to be_combat_damage

      expect(p2.life).to eq(p2_starting_life - 1)
    end

    it "p2 blocks with a vastwood gorger" do
      expect(subject.battlefield.cards).to include(loxodon_wayfarer)
      expect(subject.battlefield.cards).to include(vastwood_gorger)
      p2_starting_life = p2.life

      expect(subject.step).to be_beginning_of_combat

      subject.next_step
      expect(subject.step).to be_declare_attackers

      subject.declare_attacker(
        loxodon_wayfarer,
        target: p2,
      )

      subject.next_step
      expect(subject.step).to be_declare_blockers

      subject.declare_blocker(
        vastwood_gorger,
        target: loxodon_wayfarer,
      )

      subject.next_step
      expect(subject.step).to be_first_strike

      subject.next_step
      expect(subject.step).to be_combat_damage
      expect(loxodon_wayfarer.zone).to be_graveyard
      expect(subject.battlefield.cards).not_to include(loxodon_wayfarer)

      expect(vastwood_gorger.zone).to be_battlefield
      expect(subject.battlefield.cards).to include(vastwood_gorger)

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
