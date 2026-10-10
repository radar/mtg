# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VengefulPossession do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    go_to_main_phase!
    bears.tap!
    p1.add_mana(red: 1, green: 2)
    p1.cast(card: Card("Vengeful Possession")) do
      _1.auto_pay_mana
      _1.targeting(bears)
    end
    game.stack.resolve!
    game.tick!
  end

  it "gains control, untaps it and gives it haste" do
    expect(bears.controller).to eq(p1)
    expect(bears).to be_untapped
    expect(bears).to be_haste
  end

  it "returns control at end of turn" do
    current_turn.end!
    current_turn.cleanup!
    expect(bears.controller).to eq(p2)
  end

  it "lets you discard a card, and if you do, draw a card" do
    expect(game.choices.last).to be_a(Magic::Choice::May)
    game.resolve_choice!
    discard = game.choices.last
    expect(discard).to be_a(Magic::Choice::Discard)
    card = p1.hand.cards.first
    hand_size = p1.hand.count
    game.resolve_choice!(card: card)

    expect(p1.graveyard.cards).to include(card)
    expect(p1.hand.count).to eq(hand_size)
  end
end
