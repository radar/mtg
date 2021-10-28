require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, no blockers" do
  include_context "two player game"

  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer") }

  before do
    game.battlefield.add(loxodon_wayfarer)
  end

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "p1 deals damage to p2" do
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        loxodon_wayfarer,
        target: p2,
      )

      go_to_combat_damage!

      expect(p2.life).to eq(p2_starting_life - 1)
      expect(loxodon_wayfarer).to be_tapped
    end
  end
end
