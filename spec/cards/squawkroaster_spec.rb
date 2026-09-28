# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Squawkroaster do
  include_context "two player game"

  let!(:roaster) { ResolvePermanent("Squawkroaster", owner: p1) }

  it "has double strike and 4 toughness" do
    expect(roaster.double_strike?).to eq(true)
    expect(roaster.toughness).to eq(4)
  end

  it "has power equal to the number of colors among permanents you control" do
    game.tick!
    expect(roaster.power).to eq(1) # itself is red

    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Alaborn Trooper", owner: p1)
    game.tick!
    expect(roaster.power).to eq(3)
  end

  it "doesn't count opponent's permanents" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!
    expect(roaster.power).to eq(1)
  end
end
