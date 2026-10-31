# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MeriadocBrandybuck do
  include_context "two player game"

  let!(:meriadoc) { ResolvePermanent("Meriadoc Brandybuck", owner: p1) }
  let!(:halfling) { ResolvePermanent("Belladonna Took", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def foods = p1.permanents.select { _1.type?("Food") }

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/2 Halfling" do
    expect([meriadoc.power, meriadoc.toughness]).to eq([2, 2])
    expect(meriadoc.type?("Halfling")).to eq(true)
  end

  it "creates a Food when Meriadoc himself attacks a player" do
    attack_with(meriadoc)

    expect(foods.count).to eq(1)
  end

  it "creates a Food when another Halfling attacks a player" do
    attack_with(halfling)

    expect(foods.count).to eq(1)
  end

  it "creates only one Food however many Halflings attack" do
    attack_with(meriadoc, halfling)

    expect(foods.count).to eq(1)
  end

  it "does not trigger when only non-Halflings attack" do
    attack_with(bears)

    expect(foods).to be_empty
  end

  it "does not trigger when a Halfling attacks a planeswalker" do
    walker = ResolvePermanent("Jaya Ballard", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: halfling, target: walker)
    current_turn.attackers_declared!
    game.settle!

    expect(foods).to be_empty
  end

  it "does not trigger when an opponent's Halfling attacks you" do
    go_to_main_phase_for!(p2)
    ResolvePermanent("Belladonna Took", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker: p2.creatures.first, target: p1)
    current_turn.attackers_declared!
    game.settle!

    expect(foods).to be_empty
  end
end
