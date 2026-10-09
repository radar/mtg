# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ConfusticateAndBebother do
  include_context "two player game"

  it "offers both modes" do
    expect(described_class::MODES).to eq([described_class::CounterUnlessPay, described_class::Loot])
  end

  describe "counter mode" do
    before { go_to_main_phase_for!(p2) }

    let(:sol_ring) { Card("Sol Ring", owner: p2) }

    def counter_sol_ring
      p2.add_mana(blue: 1)
      spell = p2.cast(card: sol_ring) { _1.pay_mana(generic: { blue: 1 }) }
      p1.add_mana(blue: 3)
      p1.cast(card: Card("Confusticate And Bebother", owner: p1)) do |action|
        action.pay_mana(generic: { blue: 2 }, blue: 1)
        action.choose_mode(described_class::CounterUnlessPay) { _1.targeting(spell) }
      end
      game.stack.resolve!
    end

    it "counters the spell if its controller doesn't pay {4}" do
      counter_sol_ring
      game.resolve_choice!
      game.stack.resolve!

      expect(sol_ring.zone).to be_graveyard
    end

    it "doesn't counter the spell if its controller pays {4}" do
      counter_sol_ring
      choice = game.choices.first
      expect(choice.costs.first.generic).to eq(4)
      p2.add_mana(white: 4)
      choice.pay(p2, generic: { white: 4 })
      game.resolve_choice!
      game.stack.resolve!

      expect(sol_ring.zone).to be_battlefield
    end
  end

  describe "loot mode" do
    it "draws two cards, then discards a card" do
      hand = p1.hand.count
      p1.add_mana(blue: 3)
      p1.cast(card: Card("Confusticate And Bebother", owner: p1)) do |action|
        action.pay_mana(generic: { blue: 2 }, blue: 1)
        action.choose_mode(described_class::Loot)
      end
      game.stack.resolve!

      expect(p1.hand.count).to eq(hand + 2)
      discard = p1.hand.first
      game.resolve_choice!(card: discard)

      expect(p1.hand.count).to eq(hand + 1)
      expect(discard.zone).to be_graveyard
    end
  end
end
