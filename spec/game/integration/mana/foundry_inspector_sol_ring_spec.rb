require 'spec_helper'

RSpec.describe Magic::Game, "Mana spend -- Foundry Inspector + Free Sol Ring" do
  include_context "two player game"

  context "when at first main phase" do
    before do
      game.current_turn.go_to_beginning_of_combat!
    end

    context "with 3 mountains and a foundry inspector on the battlefield, and a sol ring in hand" do
      let(:foundry_inspector) { Card("Foundry Inspector") }
      let(:sol_ring) { Card("Sol Ring") }

      before do
        3.times { game.battlefield.add(Card("Mountain", controller: p1)) }
        p1.hand.add(foundry_inspector)
        p1.hand.add(sol_ring)
      end

      it "casts a foundry inspector and then a sol ring" do
        mountains = game.battlefield.cards.select { |c| c.name == "Mountain" }
        mountains.each { |mountain| p1.tap!(mountain) }

        expect(p1.mana_pool[:red]).to eq(3)
        expect(p1.can_cast?(foundry_inspector)).to eq(true)
        cast = p1.prepare_to_cast!(foundry_inspector)
        cast.pay(generic: { red: 3 })
        cast.perform!
        game.stack.resolve!
        expect(game.battlefield.creatures).to include(foundry_inspector)
        expect(p1.mana_pool[:red]).to eq(0)
        p1.cast!(sol_ring)
        game.stack.resolve!
        expect(sol_ring.zone).to be_battlefield
      end
    end
  end
end
