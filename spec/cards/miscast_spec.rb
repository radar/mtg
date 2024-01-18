require 'spec_helper'

RSpec.describe Magic::Cards::Miscast do
  include_context "two player game"

  subject(:miscast) { Card("Miscast") }

  context "with miscast on the stack" do
    let(:sol_ring) { Card("Sol Ring", owner: p2) }

    before do
      p2.add_mana(blue: 1)
      sol_ring_cast = p2.cast(card: sol_ring) do
        _1.pay_mana(generic: { blue: 1 })
      end

      p1.add_mana(blue: 2)
      p1.cast(card: miscast) do
        _1.pay_mana(generic: { blue: 1}, blue: 1)
        _1.targeting(sol_ring_cast)
      end
      game.tick!
    end

    it "has a 3 cost choice" do
      choice = game.choices.first
      expect(choice.costs.first.generic).to eq(3)
    end

    it "counters target spell if cost is unpaid" do
      game.resolve_choice!
      game.tick!

      expect(sol_ring.zone).to be_graveyard
    end

    it "does not counter spell if cost is paid" do
      choice = game.choices.first
      p2.add_mana(white: 3)
      choice.pay(p2, generic: { white: 3 })

      game.resolve_choice!
      game.tick!
      expect(sol_ring.zone).to be_battlefield
    end
  end
end
