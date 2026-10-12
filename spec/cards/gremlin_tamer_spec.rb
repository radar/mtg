# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GremlinTamer do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:tamer) { ResolvePermanent("Gremlin Tamer", owner: p1) }

  def gremlins = p1.creatures.select { _1.type?("Gremlin") }

  it "is a 2/2 Human Scout" do
    expect([tamer.power, tamer.toughness]).to eq([2, 2])
    expect(tamer.type?("Scout")).to be(true)
  end

  it "creates a 1/1 red Gremlin whenever an enchantment you control enters" do
    eerie_enchantment_enters!

    expect(gremlins.size).to eq(1)
    expect([gremlins.first.power, gremlins.first.toughness]).to eq([1, 1])
    expect(gremlins.first.colors).to eq([:red])
  end

  it "creates a Gremlin whenever you fully unlock a Room" do
    room = eerie_room
    expect { eerie_fully_unlock_room!(room) }.to change { gremlins.size }.by(1)
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)

    expect(gremlins).to be_empty
  end
end
