# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MossbornHydra do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:hydra) { ResolvePermanent("Mossborn Hydra", owner: p1) }

  def counters = hydra.counters.of_type(Magic::Counters["+1/+1"]).count

  it "enters with a +1/+1 counter and has trample" do
    expect(counters).to eq(1)
    expect([hydra.power, hydra.toughness]).to eq([1, 1])
    expect(hydra).to be_trample
  end

  it "doubles its +1/+1 counters when a land enters under your control" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!
    game.tick!

    expect(counters).to eq(2)
    expect([hydra.power, hydra.toughness]).to eq([2, 2])
  end

  it "doesn't trigger on an opponent's land" do
    go_to_main_phase_for!(p2)
    p2.play_land(land: Card("Mountain", owner: p2))
    game.settle!

    expect(counters).to eq(1)
  end
end
