# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpitfireLagac do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:lagac) { ResolvePermanent("Spitfire Lagac", owner: p1) }

  it "is a 3/4 Lizard" do
    expect([lagac.power, lagac.toughness]).to eq([3, 4])
  end

  it "deals 1 damage to each opponent when a land enters under your control" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "doesn't trigger on an opponent's land" do
    go_to_main_phase_for!(p2)
    p2.play_land(land: Card("Mountain", owner: p2))
    game.settle!

    expect(p2.life).to eq(20)
  end
end
