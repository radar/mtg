# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkullsnapNuisance do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:nuisance) { ResolvePermanent("Skullsnap Nuisance", owner: p1) }

  it "is a 1/4 Insect Skeleton with flying" do
    expect([nuisance.power, nuisance.toughness]).to eq([1, 4])
    expect(nuisance).to have_keyword(:flying)
  end

  it "surveils 1 whenever an enchantment you control enters" do
    eerie_enchantment_enters!

    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  it "surveils 1 whenever you fully unlock a Room" do
    room = eerie_room
    game.skip_choice! while game.choices.any?

    eerie_fully_unlock_room!(room)
    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)
    game.settle!

    expect(game.choices).to be_empty
  end
end
