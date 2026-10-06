# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PitchburnDevils do
  include_context "two player game"

  let!(:devils) { ResolvePermanent("Pitchburn Devils", owner: p1) }

  it "is a 3/3 Devil" do
    expect([devils.power, devils.toughness]).to eq([3, 3])
  end

  it "deals 3 damage to any target when it dies" do
    devils.destroy!
    game.settle!
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(17)
  end

  it "can target a creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    devils.destroy!
    game.settle!
    game.resolve_choice!(target: bears)
    game.settle!

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
  end
end
