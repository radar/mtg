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
        p1.cast(card: foundry_inspector) do
          _1.pay_mana(generic: { red: 3 })
        end

        game.stack.resolve!

        # Sol Ring cost discounted by 1 by Foundry Inspector, so is free
        p1.cast(card: sol_ring)

        game.stack.resolve!

        expect(p1.permanents.by_name(sol_ring.name).count).to eq(1)
      end
    end
  end
end
