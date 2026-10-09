# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PartInFriendship do
  include_context "two player game"

  let!(:enchantment) { ResolvePermanent("Part In Friendship", owner: p1) }
  let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:filler) { Card("Forest", owner: p1) }
  let(:cheap) { Card("Grizzly Bears", owner: p1) }
  let(:expensive) { Card("Ordinary Bear", owner: p1) }

  def stack_library(*cards)
    cards.reverse_each { p1.library.add(_1) }
  end

  it "puts a creature with mana value <= your lands onto the battlefield when a nontoken creature dies" do
    2.times { ResolvePermanent("Forest", owner: p1) }
    stack_library(filler, cheap)
    victim.destroy!
    game.settle!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    expect(p1.creatures).not_to include(victim)
    expect(cheap.zone).to be_nil.or(be_battlefield)
  end

  it "puts a more expensive creature into your hand instead" do
    stack_library(filler, expensive)
    hand_before = p1.hand.count
    victim.destroy!
    game.settle!

    expect(p1.hand.cards).to include(expensive)
    expect(p1.hand.count).to eq(hand_before + 1)
  end

  it "puts the other revealed cards on the bottom of the library" do
    stack_library(filler, expensive)
    victim.destroy!
    game.settle!

    expect(p1.library.cards.last).to eq(filler)
  end

  it "triggers only once each turn" do
    2.times { ResolvePermanent("Forest", owner: p1) }
    second = ResolvePermanent("Grizzly Bears", owner: p1)
    stack_library(Card("Forest", owner: p1), cheap, Card("Forest", owner: p1), expensive)
    victim.destroy!
    game.settle!
    hand_before = p1.hand.count
    second.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand_before)
  end

  it "doesn't trigger for a token" do
    token = Magic::Tokens::HumanSoldier.new(game: game, owner: p1).resolve!
    stack_library(filler, expensive)
    hand_before = p1.hand.count
    token.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand_before)
  end

  it "doesn't trigger for an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    stack_library(filler, expensive)
    hand_before = p1.hand.count
    theirs.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand_before)
  end
end
