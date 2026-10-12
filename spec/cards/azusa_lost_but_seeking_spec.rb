# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AzusaLostButSeeking do
  include_context "two player game"
  before { go_to_main_phase! }

  def play_forest
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    p1.play_land(land:)
  end

  it "is a legendary 1/2 Human Monk" do
    azusa = ResolvePermanent("Azusa, Lost But Seeking", owner: p1)

    expect([azusa.power, azusa.toughness]).to eq([1, 2])
    expect(azusa.type?("Monk")).to eq(true)
  end

  it "lets you play only one land per turn without it" do
    play_forest

    expect(p1.can_play_lands?).to eq(false)
  end

  it "lets you play three lands per turn with it" do
    ResolvePermanent("Azusa, Lost But Seeking", owner: p1)

    3.times { play_forest }

    expect(p1.lands.count).to eq(3)
    expect(p1.can_play_lands?).to eq(false)
  end

  it "does not help your opponent" do
    ResolvePermanent("Azusa, Lost But Seeking", owner: p1)
    go_to_main_phase_for!(p2)
    land = Card("Forest", owner: p2)
    p2.hand.add(land)
    p2.play_land(land:)

    expect(p2.can_play_lands?).to eq(false)
  end
end
