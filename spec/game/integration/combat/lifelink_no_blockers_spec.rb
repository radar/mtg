require 'spec_helper'

RSpec.describe Magic::Game, "combat -- life linker no blockers" do
  include_context "two player game"

  let(:basris_acolyte) { Card("Basri's Acolyte", controller: p1) }

  before do
    game.battlefield.add(basris_acolyte)
  end

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "p1 attacks with Basri's Acolyte" do
      p1_starting_life = p1.life
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        basris_acolyte,
        target: p2,
      )

      go_to_combat_damage!

      expect(p1.life).to eq(p1_starting_life + 2)
      expect(p2.life).to eq(p2_starting_life - 2)
    end
  end
end
