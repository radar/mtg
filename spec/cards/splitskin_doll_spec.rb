# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SplitskinDoll do
  include_context "two player game"

  it "is a 2/1 Toy artifact creature" do
    doll = ResolvePermanent("Splitskin Doll", owner: p1)
    game.settle!

    expect([doll.power, doll.toughness]).to eq([2, 1])
    expect(doll).to be_artifact
  end

  it "draws a card and discards a card when you control no other small creature" do
    hand = p1.hand.count
    ResolvePermanent("Splitskin Doll", owner: p1)
    game.settle!

    expect(p1.hand.count).to eq(hand + 1)
    card = p1.hand.cards.first
    game.resolve_choice!(card:)

    expect(card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand)
  end

  it "only draws when you control another creature with power 2 or less" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    hand = p1.hand.count
    ResolvePermanent("Splitskin Doll", owner: p1)
    game.settle!

    expect(p1.hand.count).to eq(hand + 1)
    expect(game.choices).to be_empty
  end

  it "still discards when the only other creature has power 3 or more" do
    ResolvePermanent("Vinebred Brawler", owner: p1)
    ResolvePermanent("Splitskin Doll", owner: p1)
    game.settle!

    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end
end
