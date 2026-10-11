# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NightshadeHarvester do
  include_context "two player game"

  let!(:harvester) { ResolvePermanent("Nightshade Harvester", owner: p1) }

  it "drains an opponent and grows when their land enters" do
    ResolvePermanent("Mountain", owner: p2)
    game.settle!

    expect(p2.life).to eq(19)
    expect(harvester.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    expect([harvester.power, harvester.toughness]).to eq([3, 3])
  end

  it "ignores your own lands" do
    ResolvePermanent("Swamp", owner: p1)
    game.settle!

    expect(p2.life).to eq(20)
    expect(harvester.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
  end
end
