require 'spec_helper'

RSpec.describe Magic::Game, "combat -- first striker, no blockers" do
  include_context "two player game"

  let(:battlefield_raptor) { Card("Battlefield Raptor") }

  before do
    game.battlefield.add(battlefield_raptor)
  end

  context "when in combat" do
    it "p1 attacks with battlefield raptor" do
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        battlefield_raptor,
        target: p2,
      )

      go_to_combat_damage!

      expect(p2.life).to eq(p2_starting_life - 1)
    end
  end
end
