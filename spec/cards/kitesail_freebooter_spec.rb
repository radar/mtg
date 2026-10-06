# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KitesailFreebooter do
  include_context "two player game"

  let(:bolt) { Card("Lightning Bolt", owner: p2) }
  let(:ring) { Card("Sol Ring", owner: p2) }
  let(:bears) { Card("Grizzly Bears", owner: p2) }
  let(:forest) { Card("Forest", owner: p2) }

  before do
    [*p2.hand.cards].each { p2.hand.remove(_1) }
    [bolt, ring, bears, forest].each { p2.hand.add(_1) }
  end

  it "is a 1/2 flying Human Pirate" do
    freebooter = ResolvePermanent("Kitesail Freebooter", owner: p1)
    game.settle!
    game.skip_choice! if game.choices.any?

    expect([freebooter.power, freebooter.toughness]).to eq([1, 2])
    expect(freebooter).to be_flying
  end

  it "offers only noncreature, nonland cards from the opponent's hand" do
    ResolvePermanent("Kitesail Freebooter", owner: p1)
    game.settle!

    expect(game.choices.last.choices).to contain_exactly(bolt, ring)
  end

  it "exiles the chosen card" do
    ResolvePermanent("Kitesail Freebooter", owner: p1)
    game.settle!
    game.resolve_choice!(target: bolt)

    expect(bolt.zone).to be_exile
    expect(p2.hand.cards).to include(ring, bears, forest)
  end

  it "returns the card to its owner's hand when the Freebooter leaves the battlefield" do
    freebooter = ResolvePermanent("Kitesail Freebooter", owner: p1)
    game.settle!
    game.resolve_choice!(target: bolt)
    freebooter.destroy!
    game.settle!

    expect(bolt.zone).to be_hand
    expect(p2.hand.cards).to include(bolt)
  end

  it "does nothing when the hand has no noncreature, nonland card" do
    p2.hand.remove(bolt)
    p2.hand.remove(ring)
    ResolvePermanent("Kitesail Freebooter", owner: p1)
    game.settle!

    expect(game.choices).to be_empty
  end
end
