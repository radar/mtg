# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StonyVoicedGoblins do
  include_context "two player game"

  before { go_to_main_phase! }

  it "makes each opponent discard a card when it enters" do
    card = Card("Stony Voiced Goblins", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p2_hand = p2.hand.count
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
    game.resolve_choice!(card: p2.hand.cards.first) if game.choices.any?

    expect(p2.hand.count).to eq(p2_hand - 1)
    expect(p2.graveyard.count).to eq(1)
  end
end
