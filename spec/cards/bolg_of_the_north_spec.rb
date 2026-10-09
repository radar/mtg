# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BolgOfTheNorth do
  include_context "two player game"

  def armies = p1.creatures.select { _1.type?("Army") }

  let!(:fodder) { ResolvePermanent("Baneslayer Angel", owner: p1) }
  let!(:small) { ResolvePermanent("Wood Elves", owner: p2) }
  let!(:big) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 5/5 legendary Goblin Soldier" do
    bolg = ResolvePermanent("Bolg Of The North", owner: p1)

    expect([bolg.power, bolg.toughness]).to eq([5, 5])
    expect(bolg.card.types).to include("Goblin", "Soldier")
  end

  it "deals damage equal to the sacrificed creature's power to another creature" do
    ResolvePermanent("Bolg Of The North", owner: p1)
    game.resolve_choice!(sacrifice: fodder)
    game.resolve_choice!(target: big)

    expect(p1.graveyard.cards.map(&:name)).to include("Baneslayer Angel")
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "amasses Goblins equal to the excess damage" do
    ResolvePermanent("Bolg Of The North", owner: p1)
    game.resolve_choice!(sacrifice: fodder)
    game.resolve_choice!(target: big)
    game.tick!

    # Baneslayer Angel has 5 power; Grizzly Bears has 2 toughness: excess 3.
    expect(armies.size).to eq(1)
    expect(armies.first.power).to eq(3)
  end

  it "makes no Army when there is no excess damage" do
    elves = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Bolg Of The North", owner: p1)
    game.resolve_choice!(sacrifice: elves)
    game.resolve_choice!(target: big)

    expect(armies).to be_empty
  end

  it "does nothing when you decline" do
    ResolvePermanent("Bolg Of The North", owner: p1)
    game.skip_choice!

    expect(p1.creatures).to include(fodder)
  end
end
