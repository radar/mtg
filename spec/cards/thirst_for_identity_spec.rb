# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThirstForIdentity do
  include_context "two player game"

  let(:thirst) { Card("Thirst For Identity") }

  before do
    p1.hand.add(thirst)
    p1.add_mana(blue: 3)
    p1.cast(card: thirst) { _1.auto_pay_mana }
  end

  def choice = game.choices.last

  it "draws three cards, then asks for a discard" do
    expect { game.stack.resolve! }.to change { p1.hand.count }.by(2)
    expect(choice).to be_a(described_class::DiscardChoice)
  end

  it "discards two cards" do
    game.stack.resolve!
    two = p1.hand.first(2)
    game.resolve_choice!(cards: two)
    expect(two.map(&:zone)).to all(be_graveyard)
  end

  it "discards only a creature card, instead of two" do
    bears = Card("Grizzly Bears")
    p1.hand.add(bears)
    game.stack.resolve!

    expect { game.resolve_choice!(cards: [bears]) }.to change { p1.graveyard.count }.by(1)
    expect(bears.zone).to be_graveyard
  end

  it "won't discard a single noncreature card" do
    game.stack.resolve!
    forest = p1.hand.first
    expect { game.resolve_choice!(cards: [forest]) }.to raise_error(described_class::DiscardChoice::InvalidDiscard)
  end
end
