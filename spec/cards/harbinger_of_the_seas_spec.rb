# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HarbingerOfTheSeas do
  include_context "two player game"

  it "is a 2/2 Merfolk Wizard" do
    harbinger = ResolvePermanent("Harbinger Of The Seas", owner: p1)
    expect(harbinger.power).to eq(2)
    expect(harbinger.toughness).to eq(2)
  end

  it "makes nonbasic lands of either player Islands" do
    ResolvePermanent("Harbinger Of The Seas", owner: p1)
    mine = ResolvePermanent("Urzas Cave", owner: p1)
    theirs = ResolvePermanent("Urzas Cave", owner: p2)
    game.tick!
    expect(mine.type?("Island")).to eq(true)
    expect(theirs.type?("Island")).to eq(true)
  end

  it "does not affect basic lands" do
    ResolvePermanent("Harbinger Of The Seas", owner: p1)
    mountain = ResolvePermanent("Mountain", owner: p1)
    game.tick!
    expect(mountain.type?("Island")).to eq(false)
  end
end
