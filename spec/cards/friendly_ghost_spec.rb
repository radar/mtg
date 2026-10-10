# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FriendlyGhost do
  include_context "two player game"

  it "is a 2/4 flying Spirit" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    ghost = ResolvePermanent("Friendly Ghost", owner: p1)
    game.skip_choice!

    expect([ghost.power, ghost.toughness]).to eq([2, 4])
    expect(ghost).to be_flying
  end

  it "gives target creature +2/+4 until end of turn when it enters" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Friendly Ghost", owner: p1)
    game.resolve_choice!(target: bears)
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 6])
  end
end
