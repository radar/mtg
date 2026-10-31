# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WarbeastOfGorgoroth do
  include_context "two player game"

  let!(:warbeast) { ResolvePermanent("Warbeast Of Gorgoroth", owner: p1) }

  def armies = p1.creatures.by_type("Army")

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 5/4 Beast" do
    expect([warbeast.power, warbeast.toughness]).to eq([5, 4])
    expect(warbeast.type?("Beast")).to eq(true)
  end

  it "amasses Orcs 2 when it dies" do
    warbeast.destroy!
    game.settle!

    expect(armies.size).to eq(1)
    expect(counters(armies.first)).to eq(2)
    expect(armies.first.type?("Orc")).to eq(true)
  end

  it "amasses Orcs 2 when another creature you control with power 4 or greater dies" do
    grizzly = ResolvePermanent("Alpine Grizzly", owner: p1)
    expect(grizzly.power).to eq(4)

    grizzly.destroy!
    game.settle!

    expect(armies.size).to eq(1)
    expect(counters(armies.first)).to eq(2)
  end

  it "does nothing when a creature you control with power 3 or less dies" do
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!

    expect(armies).to be_empty
  end

  it "does nothing when an opponent's creature with power 4 or greater dies" do
    ResolvePermanent("Alpine Grizzly", owner: p2).destroy!
    game.settle!

    expect(armies).to be_empty
  end

  it "adds counters to an existing Army instead of creating another" do
    ResolvePermanent("Alpine Grizzly", owner: p1).destroy!
    game.settle!
    ResolvePermanent("Alpine Grizzly", owner: p1).destroy!
    game.settle!

    expect(armies.size).to eq(1)
    expect(counters(armies.first)).to eq(4)
  end
end
