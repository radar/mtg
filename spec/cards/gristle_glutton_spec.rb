# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GristleGlutton do
  include_context "two player game"

  let!(:glutton) { ResolvePermanent("Gristle Glutton", owner: p1) }

  it "is a 1/3 goblin scout" do
    expect(glutton.card.types).to include("Goblin", "Scout")
    expect(glutton.power).to eq(1)
    expect(glutton.toughness).to eq(3)
  end

  it "discards a card, then draws a card, for {T}, Blight 1" do
    card_to_discard = Card("Forest", owner: p1)
    p1.hand.add(card_to_discard)
    library_count = p1.library.count

    p1.activate_ability(ability: glutton.activated_abilities.first) { |a| a.pay_blight(glutton) }
    game.stack.resolve!
    game.resolve_choice!(card: card_to_discard)

    expect(card_to_discard.zone).to be_graveyard
    expect(p1.library.count).to eq(library_count - 1)
    expect(glutton.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end
end
