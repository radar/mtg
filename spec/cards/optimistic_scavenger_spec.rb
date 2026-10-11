# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OptimisticScavenger do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:scavenger) { ResolvePermanent("Optimistic Scavenger", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 1/1 Human Scout" do
    expect([scavenger.power, scavenger.toughness]).to eq([1, 1])
  end

  it "puts a +1/+1 counter on target creature whenever an enchantment you control enters" do
    eerie_enchantment_enters!
    game.resolve_choice!(target: bears)

    expect(bears.power).to eq(3)
    expect(scavenger.power).to eq(1)
  end

  it "may target itself or an opposing creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    eerie_enchantment_enters!

    expect(game.choices.last.choices).to include(scavenger, bears, theirs)
    game.resolve_choice!(target: scavenger)
    expect(scavenger.power).to eq(2)
  end

  it "triggers whenever you fully unlock a Room" do
    room = eerie_room
    game.resolve_choice!(target: bears)

    eerie_fully_unlock_room!(room)
    game.resolve_choice!(target: bears)

    expect(bears.power).to eq(4)
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)
    game.settle!

    expect(game.choices).to be_empty
  end
end
