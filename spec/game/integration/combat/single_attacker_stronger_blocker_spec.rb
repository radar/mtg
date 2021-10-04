require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, stronger blocker" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer") }
  let(:vastwood_gorger) { Card("Vastwood Gorger") }

  before do
    game.battlefield.add(loxodon_wayfarer)
    game.battlefield.add(vastwood_gorger)
  end

  context "when in combat" do
    before do
      subject.go_to_beginning_of_combat!
    end

    it "p2 blocks with a vastwood gorger" do
      expect(subject.battlefield.cards).to include(loxodon_wayfarer)
      expect(subject.battlefield.cards).to include(vastwood_gorger)
      p2_starting_life = p2.life

      expect(subject).to be_at_step(:beginning_of_combat)

      subject.next_step
      expect(subject).to be_at_step(:declare_attackers)

      subject.declare_attacker(
        loxodon_wayfarer,
        target: p2,
      )

      subject.next_step
      expect(subject).to be_at_step(:declare_blockers)

      subject.declare_blocker(
        vastwood_gorger,
        target: loxodon_wayfarer,
      )

      subject.next_step
      expect(subject).to be_at_step(:first_strike)

      subject.next_step
      expect(subject).to be_at_step(:combat_damage)
      expect(loxodon_wayfarer.zone).to be_graveyard
      expect(subject.battlefield.cards).not_to include(loxodon_wayfarer)

      expect(vastwood_gorger.zone).to be_battlefield
      expect(subject.battlefield.cards).to include(vastwood_gorger)

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
