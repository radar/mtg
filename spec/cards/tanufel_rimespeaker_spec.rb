# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TanufelRimespeaker do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rimespeaker) { ResolvePermanent("Tanufel Rimespeaker", owner: p1) }

  it "is a 2/4 Elemental Wizard" do
    expect([rimespeaker.power, rimespeaker.toughness]).to eq([2, 4])
  end

  it "draws a card when you cast a spell with mana value 4 or greater" do
    card = Card("Kinbinding", owner: p1) # mana value 5
    p1.hand.add(card)
    hand = p1.hand.count
    p1.add_mana(white: 5)
    p1.cast(card:) { _1.pay_mana(generic: { white: 3 }, white: 2) }
    game.settle!

    expect(p1.hand.count).to eq(hand) # the spell left the hand, one card drawn
  end

  it "does not draw for a cheaper spell" do
    card = Card("Grizzly Bears", owner: p1)
    p1.hand.add(card)
    hand = p1.hand.count
    p1.add_mana(green: 2)
    p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(p1.hand.count).to eq(hand - 1)
  end

  it "does not draw when the opponent casts a big spell" do
    go_to_main_phase_for!(p2)
    card = Card("Kinbinding", owner: p2)
    p2.hand.add(card)
    hand = p1.hand.count
    p2.add_mana(white: 5)
    p2.cast(card:) { _1.pay_mana(generic: { white: 3 }, white: 2) }
    game.settle!

    expect(p1.hand.count).to eq(hand)
  end
end
