require 'spec_helper'

RSpec.describe Magic::Game, "combat -- first striker, no blockers" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:battlefield_raptor) { Card("Battlefield Raptor") }

  before do
    game.battlefield.add(battlefield_raptor)
  end

  context "when in combat" do
    before do
      subject.go_to_beginning_of_combat!
    end

    it "p1 attacks with battlefield raptor" do
      p2_starting_life = p2.life

      expect(subject).to be_at_step(:beginning_of_combat)

      subject.next_step
      expect(subject).to be_at_step(:declare_attackers)

      subject.declare_attacker(
        battlefield_raptor,
        target: p2,
      )

      subject.next_step
      expect(subject).to be_at_step(:declare_blockers)

      subject.next_step
      expect(subject).to be_at_step(:first_strike)

      subject.next_step
      expect(subject).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - 1)
    end
  end
end
