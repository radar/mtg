require 'spec_helper'

RSpec.describe Magic::Cards::LoftyDenial do
  include_context "two player game"

  subject(:lofty_denial) { Card("Lofty Denial") }

  context "with lofty denial on the stack" do
    let(:sol_ring) { Card("Sol Ring", owner: p2) }

    before do
      p2.add_mana(blue: 1)
      sol_ring_cast = p2.cast(card: sol_ring) do
        _1.pay_mana(generic: { blue: 1 })
      end

      p1.add_mana(blue: 2)
      p1.cast(card: lofty_denial) do
        _1.pay_mana(generic: { blue: 1}, blue: 1)
        _1.targeting(sol_ring_cast)
      end
      game.stack.resolve!
    end

    it "counters target spell if cost is unpaid" do
      game.resolve_choice!
      game.stack.resolve!

      expect(sol_ring.zone).to be_graveyard
    end

    it "does not counter spell if cost is paid" do
      choice = game.choices.first
      p2.add_mana(white: 1)
      choice.pay(p2, generic: { white: 1 })

      game.resolve_choice!
      game.stack.resolve!
      expect(sol_ring.zone).to be_battlefield
    end
  end

  context "when p1 controls creature with flying" do
    before do
      ResolvePermanent("Aven Gagglemaster", owner: p1)
    end

    it "must pay 4" do
      sol_ring = Card("Sol Ring", owner: p2)
      p2.add_mana(blue: 1)
      sol_ring_cast = p2.cast(card: sol_ring) do
        _1.pay_mana(generic: { blue: 1 })
      end

      p1.add_mana(blue: 2)
      p1.cast(card: lofty_denial) do
        _1.pay_mana(generic: { blue: 1}, blue: 1)
        _1.targeting(sol_ring_cast)
      end

      game.stack.resolve!
      choice = game.choices.first
      expect(choice.costs.first.generic).to eq(4)
    end
  end

  context "when p1 controls no creatures with flying" do
    it "must pay 1" do
      sol_ring = Card("Sol Ring", owner: p2)
      p2.add_mana(blue: 1)
      sol_ring_cast = p2.cast(card: sol_ring) do
        _1.pay_mana(generic: { blue: 1 })
      end

      p1.add_mana(blue: 2)
      p1.cast(card: lofty_denial) do
        _1.pay_mana(generic: { blue: 1}, blue: 1)
        _1.targeting(sol_ring_cast)
      end

      game.stack.resolve!
      choice = game.choices.first
      expect(choice.costs.first.generic).to eq(1)
    end
  end
end
