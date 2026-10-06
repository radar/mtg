# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CanopyStalker do
  include_context "two player game"

  let!(:stalker) { ResolvePermanent("Canopy Stalker", owner: p1) }

  it "is a 4/2 Cat that must be blocked if able" do
    expect([stalker.power, stalker.toughness]).to eq([4, 2])
    expect(stalker.must_be_blocked?).to eq(true)
  end

  it "gains 1 life when it is the only creature that died this turn" do
    stalker.destroy!
    game.settle!

    expect(p1.life).to eq(21)
  end

  it "gains 1 life for each creature that died this turn" do
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    game.settle!
    stalker.destroy!
    game.settle!

    expect(p1.life).to eq(23)
  end
end
