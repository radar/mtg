# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IrreverentGremlin do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:gremlin) { ResolvePermanent("Irreverent Gremlin", owner: p1) }

  it "is a 2/2 menace Gremlin" do
    expect([gremlin.power, gremlin.toughness]).to eq([2, 2])
    expect(gremlin).to have_keyword(Magic::Cards::Keywords::MENACE)
  end

  it "may discard then draw when another creature with power 2 or less enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    game.resolve_choice! # yes
    card = p1.hand.cards.first
    hand = p1.hand.count
    game.resolve_choice!(card:)

    expect(card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand)
  end

  it "does nothing when you decline, and can trigger again" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    game.skip_choice!
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!

    expect(game.choices.last).to be_a(described_class::MayDiscardChoice)
  end

  it "only works once each turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    game.resolve_choice!
    game.resolve_choice!(card: p1.hand.cards.first)
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!

    expect(game.choices).to be_empty
  end

  it "ignores creatures with power 3 or more and opponents' creatures" do
    ResolvePermanent("Vinebred Brawler", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!

    expect(game.choices).to be_empty
  end
end
