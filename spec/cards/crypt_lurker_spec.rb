# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CryptLurker do
  include_context "two player game"

  it "is a 3/4 Horror" do
    lurker = ResolvePermanent("Crypt Lurker", owner: p1)
    game.settle!
    game.skip_choice! if game.choices.any?

    expect([lurker.power, lurker.toughness]).to eq([3, 4])
  end

  it "may sacrifice a creature to draw a card" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    hand_size = p1.hand.count
    ResolvePermanent("Crypt Lurker", owner: p1)
    game.settle!
    game.resolve_choice!(target: bears)

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "may discard a creature card to draw a card" do
    creature_card = Card("Grizzly Bears", owner: p1)
    p1.hand.add(creature_card)
    hand_size = p1.hand.count
    ResolvePermanent("Crypt Lurker", owner: p1)
    game.settle!
    game.resolve_choice!(target: creature_card)

    expect(creature_card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand_size) # one discarded, one drawn
  end

  # With a single legal choice (Crypt Lurker itself) the choice resolves itself, so these keep a second creature around.
  it "doesn't offer the lands in your hand" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Crypt Lurker", owner: p1)
    game.settle!
    choice = game.choices.last

    expect(choice.choices.map(&:name)).not_to include("Forest", "Island")
  end

  it "may decline" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    hand_size = p1.hand.count
    ResolvePermanent("Crypt Lurker", owner: p1)
    game.settle!
    game.skip_choice!

    expect(p1.hand.count).to eq(hand_size)
  end
end
