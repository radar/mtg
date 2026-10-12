# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnwillingVessel do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:vessel) { ResolvePermanent("Unwilling Vessel", owner: p1) }

  def possession_counters = vessel.counters.of_type(Magic::Counters::Possession).count
  def spirits = p1.creatures.select { _1.type?("Spirit") }

  it "is a 3/2 Human Wizard with vigilance" do
    expect([vessel.power, vessel.toughness]).to eq([3, 2])
    expect(vessel).to have_keyword(:vigilance)
  end

  it "gets a possession counter whenever an enchantment you control enters" do
    eerie_enchantment_enters!

    expect(possession_counters).to eq(1)
  end

  it "gets a possession counter whenever you fully unlock a Room" do
    room = eerie_room
    expect(possession_counters).to eq(1)

    eerie_fully_unlock_room!(room)
    expect(possession_counters).to eq(2)
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)

    expect(possession_counters).to eq(0)
  end

  it "creates an X/X blue flying Spirit when it dies, X the counters on it" do
    eerie_enchantment_enters!
    eerie_enchantment_enters!("Elderfang Venom")
    vessel.destroy!
    game.settle!

    expect(spirits.size).to eq(1)
    expect([spirits.first.power, spirits.first.toughness]).to eq([2, 2])
    expect(spirits.first.colors).to eq([:blue])
    expect(spirits.first).to have_keyword(:flying)
  end

  it "creates a 0/0 Spirit that dies at once when it had no counters" do
    vessel.destroy!
    game.settle!

    expect(spirits).to be_empty
  end

  it "counts every kind of counter on it" do
    vessel.add_counter("+1/+1")
    eerie_enchantment_enters!
    vessel.destroy!
    game.settle!

    expect(spirits.first.power).to eq(2)
  end
end
