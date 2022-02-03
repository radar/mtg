require 'spec_helper'

RSpec.describe Magic::Game, "attackers declared" do
  include_context "two player game"

  let(:wood_elves) { Card("Wood Elves", controller: p1) }
  let(:basri_ket) { Card("Basri Ket", controller: p1) }

  before do
    p1.library.add(Card("Forest"))
    game.battlefield.add(wood_elves)
    game.battlefield.add(basri_ket)
  end

  context "with basri ket's delayed trigger" do
    before do
      basri_ket.loyalty_abilities[1].activate!
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

        pending "cannot work this out -- does it loop back to declaring attackers?"
        turn.attackers_declared!
        creatures = game.battlefield.creatures
        expect(creatures.count).to eq(2)

        soldier = creatures.find { |c| c.name == "Soldier" }
        expect(soldier).to be_tapped
        expect(turn.step?(:declare_attackers))

        current_turn.declare_attacker(
          soldier,
          target: p2,
        )

        current_turn.attackers_declared!

        current_turn.combat_damage!
        current_turn.combat_damage!

        expect(p2.life).to eq(p2_starting_life - soldier.power - wood_elves.power)
      end
    end
  end
end
