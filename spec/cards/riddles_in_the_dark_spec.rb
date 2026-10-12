# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RiddlesInTheDark do
  include_context "two player game"

  let(:riddles) { Card("Riddles In The Dark", owner: p1) }

  before do
    p1.hand.add(riddles)
    p1.add_mana(blue: 3)
    p1.cast(card: riddles) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
    game.settle!
  end

  let(:top_four) { game.choices.last.looked_at }

  it "lets you separate the top four cards into two piles" do
    expect(top_four.size).to eq(4)
    expect(top_four).to eq(p1.library.first(4))
  end

  it "puts the pile the opponent chooses into your hand and the other into your graveyard" do
    cards = top_four
    game.resolve_choice!(face_down: cards.first(1))
    hand_before = p1.hand.count
    game.resolve_choice!(pile: :face_up)

    expect(p1.hand.count).to eq(hand_before + 3)
    expect(p1.hand.cards).to include(*cards.last(3))
    expect(p1.graveyard.cards).to include(cards.first)
    expect(p1.graveyard.cards).to include(riddles)
  end

  it "can give the opponent the choice of the face-down pile" do
    cards = top_four
    game.resolve_choice!(face_down: cards.first(1))
    game.resolve_choice!(pile: :face_down)

    expect(p1.hand.cards).to include(cards.first)
    expect(p1.graveyard.cards).to include(*cards.last(3))
  end

  it "allows an empty pile" do
    cards = top_four
    game.resolve_choice!(face_down: [])
    game.resolve_choice!(pile: :face_down)

    expect(p1.graveyard.cards).to include(*cards)
  end
end
