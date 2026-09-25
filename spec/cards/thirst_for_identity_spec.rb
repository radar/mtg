# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThirstForIdentity do
  include_context "two player game"

  let(:thirst) { Card("Thirst For Identity") }
  let(:choice) { game.choices.last }

  before do
    p1.add_mana(blue: 3)
    p1.cast(card: thirst) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
  end

  it "draws three cards" do
    expect(p1.hand.count).to eq(7 + 3)
  end

  it "asks for a discard of two cards, or a creature card" do
    expect(choice).to be_a(Magic::Choice::DiscardUnless)
    expect(choice.amount).to eq(2)
    expect(choice.card_type).to eq("Creature")
  end

  it "discards two cards" do
    first, second = p1.hand.cards.first(2)
    game.resolve_choice!(cards: [first, second])

    expect(p1.hand.count).to eq(8)
    expect(p1.graveyard.cards).to include(first, second)
  end

  it "discards a single creature card instead" do
    bears = Card("Grizzly Bears")
    p1.hand.add(bears)
    game.resolve_choice!(cards: [bears])

    expect(p1.hand.count).to eq(10)
    expect(p1.graveyard.cards).to include(bears)
  end

  it "doesn't let one non-creature card stand in for two" do
    forest = p1.hand.cards.find { _1.name == "Forest" }
    expect { choice.resolve!(cards: [forest]) }.to raise_error(ArgumentError)
  end

  it "doesn't let a card outside your hand be discarded" do
    expect { choice.resolve!(cards: [Card("Grizzly Bears")]) }.to raise_error(ArgumentError)
  end
end
