# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CatCollector do
  include_context "two player game"
  before { go_to_main_phase! }

  def cats(player = p1) = player.creatures.select { _1.name == "Cat" }

  it "is a 3/2 Human Citizen" do
    collector = ResolvePermanent("Cat Collector", owner: p1)

    expect([collector.power, collector.toughness]).to eq([3, 2])
    expect(collector.type?("Citizen")).to eq(true)
  end

  it "creates a Food token when it enters" do
    ResolvePermanent("Cat Collector", owner: p1)

    expect(p1.permanents.by_name("Food").size).to eq(1)
  end

  it "creates a 1/1 white Cat the first time you gain life during your turn" do
    ResolvePermanent("Cat Collector", owner: p1)
    p1.gain_life(2)
    game.settle!

    expect(cats.size).to eq(1)
    expect([cats.first.power, cats.first.toughness]).to eq([1, 1])
    expect(cats.first.colors).to eq([:white])
  end

  it "does not create a second Cat for further life gain the same turn" do
    ResolvePermanent("Cat Collector", owner: p1)
    p1.gain_life(2)
    game.settle!
    p1.gain_life(1)
    game.settle!

    expect(cats.size).to eq(1)
  end

  it "creates a Cat again on a later turn of yours" do
    ResolvePermanent("Cat Collector", owner: p1)
    p1.gain_life(1)
    game.settle!
    2.times { game.next_turn }
    p1.gain_life(1)
    game.settle!

    expect(cats.size).to eq(2)
  end

  it "does not trigger on the opponent's turn or on an opponent's life gain" do
    ResolvePermanent("Cat Collector", owner: p1)
    p2.gain_life(3)
    game.settle!
    game.next_turn
    p1.gain_life(3)
    game.settle!

    expect(cats).to be_empty
  end
end
