# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CrossroadsWatcher do
  include_context "two player game"

  let!(:watcher) { ResolvePermanent("Crossroads Watcher", owner: p1) }

  it "is a 3/3 kithkin ranger with trample" do
    expect(watcher.card.types).to include("Kithkin", "Ranger")
    expect(watcher.power).to eq(3)
    expect(watcher.toughness).to eq(3)
    expect(watcher.trample?).to be(true)
  end

  it "gets +1/+0 until end of turn when another creature you control enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!

    expect(watcher.power).to eq(4)
    expect(watcher.toughness).to eq(3)
  end

  it "doesn't trigger for an opponent's creature entering" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!

    expect(watcher.power).to eq(3)
  end
end
