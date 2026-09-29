# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Glamermite do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:glamermite) { ResolvePermanent("Glamermite", owner: p1) }

  it "is a 2/2 Faerie Rogue with flash and flying" do
    expect([glamermite.power, glamermite.toughness]).to eq([2, 2])
    expect(glamermite).to be_flying
    expect(glamermite.has_keyword?(:flash)).to eq(true)
  end

  it "asks which mode when it enters" do
    expect(game.choices.last).to be_a(described_class::ModeChoice)
  end

  it "taps target creature" do
    game.resolve_choice!(mode: described_class::ModeChoice::TAP)
    game.resolve_choice!(target: rival)
    expect(rival).to be_tapped
  end

  it "untaps target creature" do
    rival.tap!
    game.resolve_choice!(mode: described_class::ModeChoice::UNTAP)
    game.resolve_choice!(target: rival)
    expect(rival).to be_untapped
  end

  it "can target any creature, including its own" do
    game.resolve_choice!(mode: described_class::ModeChoice::TAP)
    expect(game.choices.last.choices).to include(bears, rival, glamermite)
  end

  it "rejects an unknown mode" do
    expect { game.resolve_choice!(mode: :bounce) }.to raise_error(ArgumentError, /unknown mode/)
  end
end
