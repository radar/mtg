# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DreadwingScavenger do
  include_context "two player game"

  it "is a 2/2 flyer" do
    scavenger = ResolvePermanent("Dreadwing Scavenger", owner: p1)

    expect([scavenger.power, scavenger.toughness]).to eq([2, 2])
    expect(scavenger).to be_flying
  end

  it "draws a card then discards a card when it enters" do
    hand_size = p1.hand.count
    ResolvePermanent("Dreadwing Scavenger", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
    game.resolve_choice!(card: p1.hand.first)
    expect(p1.hand.count).to eq(hand_size)
  end

  it "draws then discards when it attacks" do
    scavenger = ResolvePermanent("Dreadwing Scavenger", owner: p1)
    game.resolve_choice!(card: p1.hand.first)
    skip_to_combat! # includes the draw step
    hand_size = p1.hand.count
    current_turn.declare_attackers!
    current_turn.declare_attacker(scavenger, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
    game.resolve_choice!(card: p1.hand.first)
    expect(p1.hand.count).to eq(hand_size)
  end

  it "gets +1/+1 and deathtouch with seven or more cards in your graveyard" do
    scavenger = ResolvePermanent("Dreadwing Scavenger", owner: p1)
    game.resolve_choice!(card: p1.hand.first)
    6.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) } # plus the discarded card
    game.tick!

    expect([scavenger.power, scavenger.toughness]).to eq([3, 3])
    expect(scavenger).to be_deathtouch
  end

  it "has neither bonus below seven cards" do
    scavenger = ResolvePermanent("Dreadwing Scavenger", owner: p1)
    game.resolve_choice!(card: p1.hand.first)
    game.tick!

    expect([scavenger.power, scavenger.toughness]).to eq([2, 2])
    expect(scavenger).not_to be_deathtouch
  end
end
