# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpectralSnatcher do
  include_context "two player game"

  let!(:snatcher) { ResolvePermanent("Spectral Snatcher", owner: p1) }

  it "is a 6/5" do
    expect(snatcher.power).to eq(6)
    expect(snatcher.toughness).to eq(5)
  end

  context "ward—discard a card" do
    let(:discard_card) { Card("Island", owner: p2) }

    before do
      p2.hand.add(discard_card)
      p2.add_mana(red: 1)
      p2.cast(card: Card("Shock", owner: p2)) { _1.pay_mana(red: 1).targeting(snatcher) }
      game.stack.resolve_top!
    end

    it "asks the opponent to pay" do
      expect(game.choices.last).to be_a(Magic::Choice::Ward)
    end

    it "counters the spell when the opponent doesn't discard" do
      game.resolve_choice!

      expect(game.stack.spells).to be_empty
      expect(snatcher.damage).to eq(0)
      expect(discard_card.zone).to be_hand
    end

    it "lets the spell resolve when the opponent discards a card" do
      game.resolve_choice!(discard: discard_card)
      game.stack.resolve!

      expect(discard_card.zone).to be_graveyard
      expect(snatcher.damage).to eq(2)
    end
  end

  it "has swampcycling {2}" do
    card = Card("Spectral Snatcher", owner: p1)
    p1.hand.add(card)
    swamp = Card("Swamp", owner: p1)
    p1.library.add(Card("Forest", owner: p1))
    p1.library.add(swamp)
    p1.add_mana(black: 2)
    p1.cycle(card:) { _1.pay_mana(generic: { black: 2 }) }
    game.choices.last.resolve!(targets: [swamp])

    expect(card.zone).to be_graveyard
    expect(swamp.zone).to be_hand
  end
end
