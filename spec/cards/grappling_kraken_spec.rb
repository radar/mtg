# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrapplingKraken do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:kraken) { ResolvePermanent("Grappling Kraken", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 5/6" do
    expect([kraken.power, kraken.toughness]).to eq([5, 6])
  end

  it "taps target creature an opponent controls and puts a stun counter on it when a land enters under your control" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!
    game.resolve_choice!(target: rival)
    game.settle!

    expect(rival).to be_tapped
    expect(other_rival).not_to be_tapped
    expect(rival.counters.of_type(Magic::Counters["stun"]).count).to eq(1)
  end

  it "keeps the creature tapped through its next untap step" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!
    game.resolve_choice!(target: rival)
    game.settle!
    go_to_main_phase_for!(p2)

    expect(rival).to be_tapped
  end
end
