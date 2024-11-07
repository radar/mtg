require "spec_helper"

RSpec.describe Magic::Cards::TeferisTutelage do
  include_context "two player game"

  subject { Card("Teferi's Tutelage") }

  before do
    p1.library.add(Card("Forest"))
    p2.library.add(Card("Plains", owner: p2))
    p2.library.add(Card("Plains", owner: p2))
  end

  it "draws a card when opponent draws a card" do

    p1.add_mana(blue: 3)

    p1.cast(card: subject) do
      _1.auto_pay_mana
    end

    game.stack.resolve!

    choice = game.choices.first
    game.resolve_choice!(card: choice.cards.first)

    choice = game.choices.first
    game.resolve_choice!(target: p2)
    expect(p2.graveyard.cards.count).to eq(2)
  end
end
