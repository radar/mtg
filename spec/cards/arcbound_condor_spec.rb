# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArcboundCondor do
  include_context "two player game"

  let!(:condor) { ResolvePermanent("Arcbound Condor", owner: p1) }
  let!(:golem) { ResolvePermanent("Forgotten Sentinel", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p2) }

  it "is a 3/3 flyer with modular 3" do
    expect([condor.power, condor.toughness]).to eq([3, 3])
    expect(condor.flying?).to eq(true)
  end

  it "shrinks an opponent's creature when another artifact enters" do
    ResolvePermanent("Forgotten Sentinel", owner: p1)
    game.resolve_choice!(target: bears)

    expect([bears.power, bears.toughness]).to eq([1, 1])
  end

  it "does not trigger for an artifact an opponent controls" do
    ResolvePermanent("Forgotten Sentinel", owner: p2)

    expect(game.choices).to be_empty
  end

  it "moves its counters to an artifact creature when it dies" do
    condor.destroy!
    game.settle!

    expect(golem.power).to eq(7)
  end

  it "can move its counters to an opponent's artifact creature" do
    theirs = ResolvePermanent("Forgotten Sentinel", owner: p2)
    game.settle!
    condor.destroy!
    game.settle!
    game.resolve_choice!(target: theirs)

    expect(theirs.power).to eq(7)
  end

  it "moves only its +1/+1 counters" do
    condor.add_counter("charge")
    condor.destroy!
    game.settle!

    expect(golem.power).to eq(7)
    expect(golem.counters.count).to eq(3)
  end
end
