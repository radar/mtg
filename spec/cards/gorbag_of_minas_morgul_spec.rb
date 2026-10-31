# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GorbagOfMinasMorgul do
  include_context "two player game"

  let!(:gorbag) { ResolvePermanent("Gorbag Of Minas Morgul", owner: p1) }
  let!(:goblin) { ResolvePermanent("Mogg Fanatic", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  def deal_combat_damage(creature, target = p2)
    game.notify!(Magic::Events::CombatDamageDealt.new(source: creature, target: target, damage: 1))
    game.settle!
  end

  it "triggers off a real combat hit by a Goblin" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(goblin, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(game.choices.last).to be_a(described_class::MaySacrificeChoice)
  end

  it "may sacrifice a Goblin that dealt combat damage to a player, then draws a card" do
    deal_combat_damage(goblin)
    hand = p1.hand.cards.count
    game.resolve_choice!
    expect(goblin.zone).to be_nil
    game.resolve_choice!(mode: described_class::ModeChoice::DRAW)
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Mogg Fanatic")
    expect(p1.hand.cards.count).to eq(hand + 1)
  end

  it "can create a Treasure instead" do
    deal_combat_damage(goblin)
    game.resolve_choice!
    game.resolve_choice!(mode: described_class::ModeChoice::TREASURE)
    game.settle!

    expect(treasures.count).to eq(1)
  end

  it "triggers for an Orc, including Gorbag itself" do
    deal_combat_damage(gorbag)
    game.resolve_choice!
    game.resolve_choice!(mode: described_class::ModeChoice::TREASURE)
    game.settle!

    expect(gorbag.zone).to be_nil
    expect(treasures.count).to eq(1)
  end

  it "declining the sacrifice keeps the creature and gives nothing" do
    hand = p1.hand.cards.count
    deal_combat_damage(goblin)
    game.skip_choice!
    game.settle!

    expect(goblin.zone).to be_battlefield
    expect(treasures).to be_empty
    expect(p1.hand.cards.count).to eq(hand)
    expect(game.choices).to be_empty
  end

  it "declining the mode (skip_choice!) after sacrificing gives nothing" do
    hand = p1.hand.cards.count
    deal_combat_damage(goblin)
    game.resolve_choice!
    game.skip_choice!
    game.settle!

    expect(goblin.zone).to be_nil
    expect(treasures).to be_empty
    expect(p1.hand.cards.count).to eq(hand)
  end

  it "ignores creatures that are neither Goblins nor Orcs" do
    deal_combat_damage(bears)

    expect(game.choices).to be_empty
  end

  it "ignores a Goblin an opponent controls" do
    theirs = ResolvePermanent("Mogg Fanatic", owner: p2)
    deal_combat_damage(theirs, p1)

    expect(game.choices).to be_empty
  end

  it "ignores combat damage dealt to a creature" do
    deal_combat_damage(goblin, bears)

    expect(game.choices).to be_empty
  end

  it "gives nothing if the creature left before the choice resolves" do
    deal_combat_damage(goblin)
    goblin.destroy!
    game.resolve_choice!
    game.settle!

    expect(game.choices).to be_empty
    expect(treasures).to be_empty
  end
end
