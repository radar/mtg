# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StalkedResearcher do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:researcher) { ResolvePermanent("Stalked Researcher", owner: p1) }

  it "is a 3/3 Human Wizard with defender that can't attack" do
    expect([researcher.power, researcher.toughness]).to eq([3, 3])
    expect(researcher).to have_keyword(:defender)
    expect(researcher.can_attack?).to be(false)
  end

  it "can attack this turn whenever an enchantment you control enters" do
    eerie_enchantment_enters!

    expect(researcher.can_attack?).to be(true)
  end

  it "can attack this turn whenever you fully unlock a Room" do
    room = eerie_room
    researcher.card.may_attack_turn = nil
    expect(researcher.can_attack?).to be(false)

    eerie_fully_unlock_room!(room)
    expect(researcher.can_attack?).to be(true)
  end

  it "can't attack on a later turn" do
    eerie_enchantment_enters!
    current_turn.end!
    current_turn.cleanup!
    game.next_turn

    expect(researcher.can_attack?).to be(false)
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)

    expect(researcher.can_attack?).to be(false)
  end
end
