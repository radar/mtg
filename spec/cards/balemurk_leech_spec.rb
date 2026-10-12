# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BalemurkLeech do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:leech) { ResolvePermanent("Balemurk Leech", owner: p1) }

  it "is a 2/2 Leech" do
    expect([leech.power, leech.toughness]).to eq([2, 2])
    expect(leech.type?("Leech")).to be(true)
  end

  it "makes each opponent lose 1 life whenever an enchantment you control enters" do
    expect { eerie_enchantment_enters! }.to change(p2, :life).by(-1)
    expect(p1.life).to eq(20)
  end

  it "makes each opponent lose 1 life whenever you fully unlock a Room" do
    room = eerie_room
    expect { eerie_fully_unlock_room!(room) }.to change(p2, :life).by(-1)
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    expect { ResolvePermanent("Sanctum Of Calm Waters", owner: p2) }.not_to change(p2, :life)
  end
end
