# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CultHealer do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:healer) { ResolvePermanent("Cult Healer", owner: p1) }

  def lifelink? = healer.has_keyword?(Magic::Cards::Keywords::LIFELINK)

  it "is a 3/3 Human Doctor without lifelink" do
    expect([healer.power, healer.toughness]).to eq([3, 3])
    expect(lifelink?).to be(false)
  end

  it "gains lifelink until end of turn whenever an enchantment you control enters" do
    eerie_enchantment_enters!

    expect(lifelink?).to be(true)
    current_turn.end!
    current_turn.cleanup!
    expect(lifelink?).to be(false)
  end

  it "gains lifelink whenever you fully unlock a Room" do
    room = eerie_room
    expect(lifelink?).to be(true) # the Room entering set Eerie off already
    healer.cleanup!
    expect(lifelink?).to be(false)

    eerie_fully_unlock_room!(room)
    expect(lifelink?).to be(true)
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)

    expect(lifelink?).to be(false)
  end
end
