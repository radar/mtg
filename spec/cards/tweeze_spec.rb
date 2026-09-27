# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Tweeze do
  include_context "two player game"
  before { p1.add_mana(red: 3) }

  def cast!
    p1.cast(card: Card("Tweeze", owner: p1)) { |a| a.pay_mana(generic: { red: 2 }, red: 1).targeting(p2) }
    game.stack.resolve!
  end

  it "deals 3 damage to any target" do
    cast!
    game.skip_choice!

    expect(p2.life).to eq(17)
  end

  it "draws a card if a card is discarded" do
    card_to_discard = Card("Forest", owner: p1)
    p1.hand.add(card_to_discard)
    library_count = p1.library.count

    cast!
    game.resolve_choice! # accept the "may"
    game.resolve_choice!(card: card_to_discard)

    expect(card_to_discard.zone).to be_graveyard
    expect(p1.library.count).to eq(library_count - 1)
  end

  it "does not draw a card when declined" do
    library_count = p1.library.count

    cast!
    game.skip_choice!

    expect(p1.library.count).to eq(library_count)
  end
end
