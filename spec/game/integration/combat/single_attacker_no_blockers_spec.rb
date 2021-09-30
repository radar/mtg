require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, no blockers" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer") }

  before do
    game.battlefield.add(loxodon_wayfarer)
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
      expect(loxodon_wayfarer).to be_tapped
    end
  end
end
