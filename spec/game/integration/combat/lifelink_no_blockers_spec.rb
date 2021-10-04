require 'spec_helper'

RSpec.describe Magic::Game, "combat -- life linker no blockers" do
  subject(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:basris_acolyte) { Card("Basri's Acolyte", controller: p1) }

  before do
    game.battlefield.add(basris_acolyte)
  end

  context "when in combat" do
    before do
      subject.go_to_beginning_of_combat!
    end

    it "p1 attacks with Basri's Acolyte" do
      p1_starting_life = p1.life
      p2_starting_life = p2.life

      expect(subject).to be_at_step(:beginning_of_combat)

      subject.next_step
      expect(subject).to be_at_step(:declare_attackers)

      subject.declare_attacker(
        basris_acolyte,
        target: p2,
      )

      subject.next_step
      expect(subject).to be_at_step(:declare_blockers)

      subject.next_step
      expect(subject).to be_at_step(:first_strike)

      subject.next_step
      expect(subject).to be_at_step(:combat_damage)


      expect(p1.life).to eq(p1_starting_life + 2)
      expect(p2.life).to eq(p2_starting_life - 2)
    end
  end
end
