# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SarkhanDragonAscendant do
  include_context "two player game"

  def treasures = p1.permanents.count { _1.name == "Treasure" }

  it "creates a Treasure when it enters and you behold a Dragon from your hand" do
    p1.hand.add(Card("Adult Gold Dragon", owner: p1))
    ResolvePermanent("Sarkhan, Dragon Ascendant", owner: p1)
    game.resolve_choice!
    expect(treasures).to eq(1)
  end

  it "creates nothing if you decline" do
    p1.hand.add(Card("Adult Gold Dragon", owner: p1))
    ResolvePermanent("Sarkhan, Dragon Ascendant", owner: p1)
    game.skip_choice!
    expect(treasures).to eq(0)
  end

  it "doesn't ask when there is no Dragon to behold" do
    ResolvePermanent("Sarkhan, Dragon Ascendant", owner: p1)
    expect(game.choices).to be_empty
  end

  it "beholds a Dragon you control, too" do
    ResolvePermanent("Adult Gold Dragon", owner: p1)
    ResolvePermanent("Sarkhan, Dragon Ascendant", owner: p1)
    expect(game.choices.last).to be_a(Magic::Choice::Behold)
  end

  it "gets a +1/+1 counter and becomes a flying Dragon until end of turn when a Dragon enters" do
    sarkhan = ResolvePermanent("Sarkhan, Dragon Ascendant", owner: p1)
    ResolvePermanent("Adult Gold Dragon", owner: p1)
    game.tick!
    expect(sarkhan.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    expect(sarkhan.type?("Dragon")).to be(true)
    expect(sarkhan.keywords).to include(Magic::Cards::Keywords::FLYING)
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(sarkhan.type?("Dragon")).to be(false)
  end

  it "ignores a Dragon an opponent controls" do
    sarkhan = ResolvePermanent("Sarkhan, Dragon Ascendant", owner: p1)
    ResolvePermanent("Adult Gold Dragon", owner: p2)
    game.tick!
    expect(sarkhan.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
  end
end
