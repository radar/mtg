require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, no blockers -- nine lives prevents damage" do
  include_context "two player game"

  let(:nine_lives) { Card("Nine Lives", controller: p2) }
  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", controller: p1) }

  before do
    game.battlefield.add(nine_lives)
  end

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "damage is prevented, and nine lives counter increases" do
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        loxodon_wayfarer,
        target: p2,
      )

      go_to_combat_damage!
      game.tick!
      expect(p2.life).to eq(p2_starting_life)
      expect(nine_lives.counters.count).to eq(1)
    end

    context "when counters are 8" do
      before do
        8.times { nine_lives.counters << Magic::Counters::Incarnation.new }
      end

      it "damage is prevented, and nine lives counter increases, nine live is exiled, player loses the game" do
        p2_starting_life = p2.life

        current_turn.declare_attackers!

        current_turn.declare_attacker(
          loxodon_wayfarer,
          target: p2,
        )

        go_to_combat_damage!
        game.tick!
        expect(p2.life).to eq(p2_starting_life)
        expect(nine_lives.counters.count).to eq(9)
        expect(nine_lives.zone).to be_exile
        expect(nine_lives.controller.lost?).to eq(true)
      end
    end
  end
end
