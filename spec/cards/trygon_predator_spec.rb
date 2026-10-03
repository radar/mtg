# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TrygonPredator do
  include_context "two player game"

  let!(:trygon) { ResolvePermanent("Trygon Predator", owner: p1) }
  let!(:their_stone) { ResolvePermanent("Mind Stone", owner: p2) }
  let!(:their_arena) { ResolvePermanent("Phyrexian Arena", owner: p2) }
  let!(:my_stone) { ResolvePermanent("Mind Stone", owner: p1) }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(trygon, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a 2/3 Beast with flying" do
    expect([trygon.power, trygon.toughness]).to eq([2, 3])
    expect(trygon).to be_flying
  end

  it "lets you destroy an artifact or enchantment the damaged player controls after dealing combat damage" do
    attack
    expect(game.choices.last).to be_a(Magic::Cards::TrygonPredator::CombatDamageTrigger::MayChoice)
    game.resolve_choice!
    choice = game.choices.last
    expect(choice.choices).to contain_exactly(their_stone, their_arena)
    game.resolve_choice!(target: their_arena)
    game.settle!

    expect(their_arena.card.zone).to be_graveyard
    expect(their_stone.zone).to be_battlefield
  end

  it "can destroy an artifact" do
    attack
    game.resolve_choice!
    game.resolve_choice!(target: their_stone)
    game.settle!

    expect(their_stone.card.zone).to be_graveyard
  end

  it "does nothing if you decline" do
    attack
    game.skip_choice!

    expect(game.choices).to be_empty
    expect(their_stone.zone).to be_battlefield
    expect(their_arena.zone).to be_battlefield
  end

  it "doesn't offer your own artifact" do
    attack
    game.resolve_choice!

    expect(game.choices.last.choices).not_to include(my_stone)
  end

  it "does nothing when it is blocked" do
    blocker = ResolvePermanent("Serra Angel", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(trygon, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: trygon)
    go_to_combat_damage!
    game.settle!

    expect(game.choices).to be_empty
  end

  it "does nothing when the opponent has no artifact or enchantment" do
    their_stone.destroy!
    their_arena.destroy!
    game.settle!
    attack

    expect(game.choices).to be_empty
  end
end
