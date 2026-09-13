# frozen_string_literal: true
require "spec_helper"

RSpec.describe Magic::Cards::FaithlessLooting do
  include_context "two player game"

  let(:faithless_looting) { Card("Faithless Looting") }

  context "casting from hand" do
    before do
      p1.hand.add(faithless_looting)
    end

    it "draws two cards, then discards two cards" do
      p1.add_mana(red: 1)
      hand_before = p1.hand.cards.count

      p1.cast(card: faithless_looting) do
        _1.pay_mana(red: 1)
      end
      game.stack.resolve!

      expect(p1.hand.cards.count).to eq(hand_before - 1 + 2)

      discard1 = p1.hand.cards.first
      game.resolve_choice!(card: discard1)
      discard2 = p1.hand.cards.first
      game.resolve_choice!(card: discard2)

      expect(p1.graveyard.cards).to include(discard1, discard2)
      expect(p1.hand.cards.count).to eq(hand_before - 1)
    end

    it "moves to the graveyard after resolving" do
      p1.add_mana(red: 1)

      p1.cast(card: faithless_looting) do
        _1.pay_mana(red: 1)
      end
      game.stack.resolve!

      game.resolve_choice!(card: p1.hand.cards.first)
      game.resolve_choice!(card: p1.hand.cards.first)

      expect(faithless_looting.zone).to be_graveyard
    end
  end

  context "flashback from graveyard" do
    before do
      faithless_looting.move_to_graveyard!(p1)
    end

    it "can be cast from graveyard with flashback cost and exiled after" do
      p1.add_mana(red: 3)
      action = cast_action(player: p1, card: faithless_looting, flashback: true)
      expect(action.mana_cost).to eq(Magic::Costs::Mana.new(generic: 2, red: 1))

      game.stack.add(action)
      game.stack.resolve!

      game.resolve_choice!(card: p1.hand.cards.first)
      game.resolve_choice!(card: p1.hand.cards.first)

      expect(faithless_looting.zone).to be_exile
      expect(p1.graveyard.by_name("Faithless Looting")).to be_empty
    end
  end
end
