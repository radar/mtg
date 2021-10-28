require 'spec_helper'

RSpec.describe Magic::Game, "attackers declared" do
  include_context "two player game"

  let(:wood_elves) { Card("Wood Elves", controller: p1) }
  let(:basri_ket) { Card("Basri Ket", controller: p1) }

  before do
    p1.library.add(Card("Forest"))
    game.battlefield.add(wood_elves)
  end

  context "with basri ket's delayed trigger" do
    before do
      current_turn.after_attackers_declared(basri_ket.method(:after_attackers_declared))
    end

    context "when in combat" do
      before do
        skip_to_combat!
      end

      it "creates a 1/1 white soldier creature token" do
        turn = current_turn
        p2_starting_life = p2.life

        turn.declare_attackers!

        turn.declare_attacker(
          wood_elves,
          target: p2
        )

        turn.attackers_declared!
        creatures = game.battlefield.creatures
        expect(creatures.count).to eq(2)

        soldier = creatures.find { |c| c.name == "Soldier" }
        expect(soldier).to be_tapped

        current_turn.declare_attacker(
          soldier,
          target: p2,
        )

        current_turn.extra_attackers_declared!
        expect(current_turn).to be_at_step(:declare_blockers)

        current_turn.first_strike!
        current_turn.combat_damage!

        expect(p2.life).to eq(p2_starting_life - soldier.power - wood_elves.power)
      end
    end
  end
end
