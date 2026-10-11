# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MorbidOpportunist do
  include_context "two player game"

  let!(:opportunist) { ResolvePermanent("Morbid Opportunist", owner: p1) }

  before { go_to_main_phase! }

  it "draws a card when another creature dies" do
    hand = p1.hand.cards.count
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(p1.hand.cards.count).to eq(hand + 1)
  end

  it "draws only once each turn" do
    hand = p1.hand.cards.count
    2.times { ResolvePermanent("Grizzly Bears", owner: p2).destroy! }
    game.settle!

    expect(p1.hand.cards.count).to eq(hand + 1)
  end

  it "draws again on a later turn" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    go_to_main_phase_for!(p2)
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    go_to_main_phase_for!(p1)
    hand = p1.hand.cards.count
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(p1.hand.cards.count).to eq(hand + 1)
  end

  it "doesn't trigger when it dies itself" do
    hand = p1.hand.cards.count
    opportunist.destroy!
    game.settle!

    expect(p1.hand.cards.count).to eq(hand)
  end
end
