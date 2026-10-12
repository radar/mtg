# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OriKeeperOfSongs do
  include_context "two player game"

  let!(:ori) { ResolvePermanent("Ori Keeper Of Songs", owner: p1) }

  it "is a 3/3 without an enduring story" do
    ResolvePermanent("Mind Stone", owner: p1)
    game.tick!

    expect([ori.power, ori.toughness]).to eq([3, 3])
    expect(ori).not_to have_keyword(:vigilance)
  end

  it "gets +1/+0 and vigilance once you control three artifacts, legendaries and/or Sagas" do
    # Ori is itself legendary, so two more are enough.
    2.times { ResolvePermanent("Mind Stone", owner: p1) }
    game.tick!

    expect([ori.power, ori.toughness]).to eq([4, 3])
    expect(ori).to have_keyword(:vigilance)
  end

  it "keeps the enduring story after the permanents leave" do
    stones = Array.new(2) { ResolvePermanent("Mind Stone", owner: p1) }
    game.tick!
    stones.each(&:destroy!)
    game.settle!
    game.tick!

    expect(ori.power).to eq(4)
    expect(ori).to have_keyword(:vigilance)
  end

  it "doesn't count an opponent's permanents" do
    2.times { ResolvePermanent("Mind Stone", owner: p2) }
    game.tick!

    expect(ori.power).to eq(3)
  end
end
