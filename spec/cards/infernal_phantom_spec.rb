# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InfernalPhantom do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:phantom) { ResolvePermanent("Infernal Phantom", owner: p1) }

  it "is a 2/3 Spirit" do
    expect([phantom.power, phantom.toughness]).to eq([2, 3])
  end

  it "gets +2/+0 until end of turn whenever an enchantment you control enters" do
    eerie_enchantment_enters!

    expect(phantom.power).to eq(4)
    phantom.cleanup!
    expect(phantom.power).to eq(2)
  end

  it "gets +2/+0 whenever you fully unlock a Room" do
    room = eerie_room
    eerie_fully_unlock_room!(room)

    expect(phantom.power).to eq(6)
  end

  it "deals damage equal to its power to any target when it dies" do
    phantom.destroy!
    game.settle!

    expect(game.choices.last.choices).to include(p2, p1)
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(18)
  end

  it "uses its power as it died, including Eerie bonuses" do
    eerie_enchantment_enters!
    phantom.destroy!
    game.settle!
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(16)
  end
end
