# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DashingBloodsucker do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:bloodsucker) { ResolvePermanent("Dashing Bloodsucker", owner: p1) }

  def lifelink? = bloodsucker.has_keyword?(Magic::Cards::Keywords::LIFELINK)

  it "is a 2/5 Vampire Warrior" do
    expect([bloodsucker.power, bloodsucker.toughness]).to eq([2, 5])
    expect(lifelink?).to be(false)
  end

  it "gets +2/+0 and lifelink until end of turn whenever an enchantment you control enters" do
    eerie_enchantment_enters!

    expect([bloodsucker.power, bloodsucker.toughness]).to eq([4, 5])
    expect(lifelink?).to be(true)
    bloodsucker.cleanup!
    expect([bloodsucker.power, lifelink?]).to eq([2, false])
  end

  it "triggers whenever you fully unlock a Room" do
    room = eerie_room
    bloodsucker.cleanup!
    expect(bloodsucker.power).to eq(2)

    eerie_fully_unlock_room!(room)
    expect([bloodsucker.power, lifelink?]).to eq([4, true])
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)

    expect(bloodsucker.power).to eq(2)
  end
end
