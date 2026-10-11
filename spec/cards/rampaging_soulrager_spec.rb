# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RampagingSoulrager do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:soulrager) { ResolvePermanent("Rampaging Soulrager", owner: p1) }

  def stats
    game.tick!
    [soulrager.power, soulrager.toughness]
  end

  it "is a 1/4 Spirit" do
    expect(stats).to eq([1, 4])
  end

  it "stays a 1/4 with one unlocked door" do
    ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:left])

    expect(stats).to eq([1, 4])
  end

  it "gets +3/+0 with two unlocked doors in one Room" do
    ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: %i[left right])

    expect(stats).to eq([4, 4])
  end

  it "gets +3/+0 with one unlocked door in each of two Rooms" do
    ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:left])
    ResolvePermanent("Glassworks Shattered Yard", owner: p1, doors: [:left])

    expect(stats).to eq([4, 4])
  end

  it "does not count Rooms an opponent controls" do
    ResolvePermanent("Funeral Room Awakening Hall", owner: p2, doors: %i[left right])

    expect(stats).to eq([1, 4])
  end

  it "loses the bonus when a door is locked again" do
    room = ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: %i[left right])
    expect(stats).to eq([4, 4])

    room.lock_door!(:right)
    expect(stats).to eq([1, 4])
  end
end
