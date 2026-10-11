# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ErraticApparition do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:apparition) { ResolvePermanent("Erratic Apparition", owner: p1) }

  def stats = [apparition.power, apparition.toughness]

  it "is a 1/3 Spirit with flying and vigilance" do
    expect(stats).to eq([1, 3])
    expect(apparition).to have_keyword(:flying)
    expect(apparition).to have_keyword(:vigilance)
  end

  it "gets +1/+1 until end of turn whenever an enchantment you control enters" do
    eerie_enchantment_enters!

    expect(stats).to eq([2, 4])
    apparition.cleanup!
    expect(stats).to eq([1, 3])
  end

  it "gets another +1/+1 whenever you fully unlock a Room" do
    room = eerie_room
    expect(stats).to eq([2, 4])

    eerie_fully_unlock_room!(room)
    expect(stats).to eq([3, 5])
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)

    expect(stats).to eq([1, 3])
  end
end
