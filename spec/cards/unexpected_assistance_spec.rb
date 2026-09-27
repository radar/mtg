# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnexpectedAssistance do
  include_context "two player game"

  it "has convoke" do
    expect(Card("Unexpected Assistance").convoke?).to be(true)
  end

  it "draws three cards, then discards a card" do
    p1.add_mana(blue: 5)
    card_to_discard = Card("Forest", owner: p1)
    p1.hand.add(card_to_discard)
    library_count = p1.library.count

    p1.cast(card: Card("Unexpected Assistance", owner: p1)) { |a| a.pay_mana(generic: { blue: 3 }, blue: 2) }
    game.stack.resolve!
    game.resolve_choice!(card: card_to_discard)

    expect(p1.library.count).to eq(library_count - 3)
    expect(card_to_discard.zone).to be_graveyard
  end
end
