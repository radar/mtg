# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DarksteelColossus do
  include_context "two player game"

  let(:colossus_card) { Card("Darksteel Colossus", owner: p1) }

  it "is an 11/11 indestructible trampler" do
    colossus = ResolvePermanent("Darksteel Colossus", owner: p1)

    expect([colossus.power, colossus.toughness]).to eq([11, 11])
    expect(colossus.has_keyword?(:trample)).to eq(true)
    expect(colossus.has_keyword?(:indestructible)).to eq(true)
  end

  it "is shuffled into its owner's library instead of dying when sacrificed" do
    colossus = ResolvePermanent("Darksteel Colossus", owner: p1)
    library_size = p1.library.cards.count
    colossus.sacrifice!
    game.settle!

    expect(colossus.card.zone).to be_library
    expect(p1.library.cards).to include(colossus.card)
    expect(p1.library.cards.count).to eq(library_size + 1)
    expect(p1.graveyard.cards).not_to include(colossus.card)
    expect(game.battlefield.permanents).not_to include(colossus)
  end

  it "goes to its owner's library even when an opponent controls it" do
    colossus = ResolvePermanent("Darksteel Colossus", owner: p1)
    colossus.controller = p2
    colossus.sacrifice!
    game.settle!

    expect(p1.library.cards).to include(colossus.card)
    expect(p2.library.cards).not_to include(colossus.card)
  end

  it "is shuffled into the library instead of being discarded" do
    p1.hand.add(colossus_card)
    colossus_card.discard!

    expect(colossus_card.zone).to be_library
    expect(p1.graveyard.cards).not_to include(colossus_card)
  end

  it "is shuffled into the library instead of being milled" do
    p1.library.add(colossus_card)
    p1.mill(1)

    expect(colossus_card.zone).to be_library
    expect(p1.graveyard.cards).not_to include(colossus_card)
  end

  it "doesn't affect other cards" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    bears.discard!

    expect(bears.zone).to be_graveyard
  end
end
