# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThievesGuildEnforcer do
  include_context "two player game"

  def enforcer = ResolvePermanent("Thieves' Guild Enforcer", owner: p1)

  it "is a 1/1 Human Rogue with flash" do
    creature = enforcer

    expect([creature.power, creature.toughness]).to eq([1, 1])
    expect(creature.has_keyword?(Magic::Cards::Keywords::FLASH)).to eq(true)
  end

  it "mills each opponent two cards when it enters" do
    library_count = p2.library.count
    enforcer
    game.settle!

    expect(p2.library.count).to eq(library_count - 2)
    expect(p2.graveyard.cards.count).to eq(2)
  end

  it "mills each opponent two cards when another Rogue you control enters" do
    enforcer
    game.settle!
    ResolvePermanent("Tavern Swindler", owner: p1)
    game.settle!

    expect(p2.graveyard.cards.count).to eq(4)
  end

  it "ignores a non-Rogue entering, and a Rogue an opponent controls" do
    enforcer
    game.settle!
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Tavern Swindler", owner: p2)
    game.settle!

    expect(p2.graveyard.cards.count).to eq(2)
  end

  it "gets +2/+1 and deathtouch while an opponent has eight or more cards in their graveyard" do
    creature = enforcer
    game.settle!
    expect([creature.power, creature.toughness]).to eq([1, 1])
    expect(creature).not_to be_deathtouch

    6.times { p2.graveyard.add(Card("Forest", owner: p2)) }
    game.tick!

    expect([creature.power, creature.toughness]).to eq([3, 2])
    expect(creature).to be_deathtouch
  end
end
