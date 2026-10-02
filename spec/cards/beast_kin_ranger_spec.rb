# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BeastKinRanger do
  include_context "two player game"

  let!(:ranger) { ResolvePermanent("Beast-Kin Ranger", owner: p1) }

  it "is a 3/3 trampler" do
    expect([ranger.power, ranger.toughness]).to eq([3, 3])
    expect(ranger).to be_trample
  end

  it "gets +1/+0 until end of turn when another creature enters under your control" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(ranger.power).to eq(4)
  end

  it "doesn't trigger when an opponent's creature enters" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(ranger.power).to eq(3)
  end

  it "wears off at end of turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(ranger.power).to eq(3)
  end
end
