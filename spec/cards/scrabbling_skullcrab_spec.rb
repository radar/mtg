# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScrabblingSkullcrab do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:skullcrab) { ResolvePermanent("Scrabbling Skullcrab", owner: p1) }

  it "is a 0/3 Crab Skeleton" do
    expect([skullcrab.power, skullcrab.toughness]).to eq([0, 3])
  end

  it "has target player mill two cards whenever an enchantment you control enters" do
    eerie_enchantment_enters!
    expect(game.choices.last.choices).to contain_exactly(p1, p2)

    expect { game.resolve_choice!(target: p2) }.to change { p2.library.count }.by(-2)
    expect(p2.graveyard.cards.count).to eq(2)
  end

  it "may target itself" do
    eerie_enchantment_enters!

    expect { game.resolve_choice!(target: p1) }.to change { p1.library.count }.by(-2)
  end

  it "triggers whenever you fully unlock a Room" do
    room = eerie_room
    game.resolve_choice!(target: p2)
    expect(p2.graveyard.cards.count).to eq(2)

    eerie_fully_unlock_room!(room)
    expect(game.choices.last).to be_a(described_class::MillChoice)
  end

  it "does nothing when an enchantment enters under your opponent's control" do
    ResolvePermanent("Sanctum Of Calm Waters", owner: p2)
    game.settle!

    expect(game.choices).to be_empty
  end
end
