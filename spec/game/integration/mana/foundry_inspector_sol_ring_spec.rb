require 'spec_helper'

RSpec.describe Magic::Game, "Mana spend -- Foundry Inspector + Free Sol Ring" do
  include_context "two player game"

  context "when at first main phase" do
    before do
      current_turn.untap!
      current_turn.upkeep!
      current_turn.draw!
      current_turn.first_main!
    end

    context "foundry inspector reduces sol ring cost" do
      let(:foundry_inspector) { Card("Foundry Inspector") }
      let(:sol_ring) { Card("Sol Ring") }

      before do
        p1.hand.add(foundry_inspector)
        p1.hand.add(sol_ring)
      end

      it "casts a foundry inspector and then a sol ring" do
        p1.add_mana(red: 3)
        action = Magic::Actions::Cast.new(player: p1, card: foundry_inspector)
        expect(action.can_perform?).to eq(true)
        action.pay_mana(generic: { red: 3 } )
        game.take_action(action)
        game.tick!

        action = Magic::Actions::Cast.new(player: p1, card: sol_ring)
        expect(action.can_perform?).to eq(true)
        game.take_action(action)

        game.tick!
        expect(p1.permanents.by_name(sol_ring.name).count).to eq(1)
      end
    end
  end
end
