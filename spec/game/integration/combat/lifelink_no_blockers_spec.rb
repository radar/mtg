require 'spec_helper'

RSpec.describe Magic::Game, "combat -- life linker no blockers" do
  include_context "two player game"

  let(:basris_acolyte) { Card("Basri's Acolyte", controller: p1) }

  before do
    game.battlefield.add(basris_acolyte)
  end

  context "when in combat" do
    before do
      current_turn.go_to_beginning_of_combat!
    end

    it "p1 attacks with Basri's Acolyte" do
      p1_starting_life = p1.life
      p2_starting_life = p2.life

      expect(current_turn).to be_at_step(:beginning_of_combat)

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_attackers)

      current_turn.declare_attacker(
        basris_acolyte,
        target: p2,
      )

      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_blockers)

      current_turn.next_step
      expect(current_turn).to be_at_step(:first_strike)

      current_turn.next_step
      expect(current_turn).to be_at_step(:combat_damage)


      expect(p1.life).to eq(p1_starting_life + 2)
      expect(p2.life).to eq(p2_starting_life - 2)
    end
  end
end
