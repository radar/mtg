# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BloodtitheCollector do
  include_context "two player game"

  it "is a 3/4 flying Vampire Noble" do
    collector = ResolvePermanent("Bloodtithe Collector", owner: p1)

    expect([collector.power, collector.toughness]).to eq([3, 4])
    expect(collector).to be_flying
  end

  it "makes each opponent discard a card when it enters if an opponent lost life this turn" do
    p2.lose_life(1)
    hand_size = p2.hand.count
    ResolvePermanent("Bloodtithe Collector", owner: p1)
    game.settle!
    game.resolve_choice!(card: p2.hand.first)

    expect(p2.hand.count).to eq(hand_size - 1)
  end

  it "does nothing when no opponent lost life this turn" do
    hand_size = p2.hand.count
    ResolvePermanent("Bloodtithe Collector", owner: p1)
    game.settle!

    expect(game.choices).to be_empty
    expect(p2.hand.count).to eq(hand_size)
  end

  it "does nothing when only you lost life this turn" do
    p1.lose_life(1)
    hand_size = p2.hand.count
    ResolvePermanent("Bloodtithe Collector", owner: p1)
    game.settle!

    expect(game.choices).to be_empty
    expect(p2.hand.count).to eq(hand_size)
  end
end
