require 'spec_helper'

RSpec.describe Magic::Game, "attackers declared" do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p1) }
  let!(:basri_ket) { ResolvePermanent("Basri Ket", controller: p1) }

  before do
    p1.library.add(Card("Forest"))
  end

  context "with basri ket's delayed trigger" do
    before do
      basri_ket.change_loyalty!(7)
      action = Magic::Actions::ActivateLoyaltyAbility.new(player: p1, planeswalker: basri_ket, ability: basri_ket.loyalty_abilities[1])
      game.take_action(action)
      game.stack.resolve!
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
        expect(current_turn.step?(:finalize_attackers)).to eq(true)

        current_turn.declare_attacker(
          soldier,
          target: p2,
        )

        current_turn.attackers_finalized!

        current_turn.combat_damage!

        expect(p2.life).to eq(p2_starting_life - soldier.power - wood_elves.power)
      end
    end
  end
end
