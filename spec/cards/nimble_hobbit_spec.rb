# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NimbleHobbit do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:hobbit) { ResolvePermanent("Nimble Hobbit", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def foods = p1.permanents.select { _1.type?("Food") }

  def food = Magic::Tokens::Food.new(game: game, owner: p1).resolve!

  def attack!(creature = hobbit)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 1/3 Halfling Peasant" do
    expect([hobbit.power, hobbit.toughness]).to eq([1, 3])
    expect(hobbit.type?("Halfling")).to be(true)
  end

  it "sacrifices a Food on attack, then taps the chosen opponent creature" do
    fodder = food
    attack!

    expect(game.choices.last).to be_a(described_class::CostChoice)
    game.resolve_choice!(sacrifice: fodder)
    expect(foods).to be_empty
    expect(game.choices.last).to be_a(described_class::TapChoice)
    expect(game.choices.last.choices).to match_array([theirs, other_theirs])
    game.resolve_choice!(target: theirs)
    game.settle!

    expect(theirs).to be_tapped
    expect(other_theirs).not_to be_tapped
    expect(mine).not_to be_tapped
  end

  it "pays {2}{W} on attack, then taps the chosen opponent creature" do
    p1.add_mana(white: 3)
    attack!

    game.resolve_choice!(pay: true)
    game.resolve_choice!(target: other_theirs)
    game.settle!

    expect(p1.mana_pool.values.sum).to eq(0)
    expect(other_theirs).to be_tapped
    expect(theirs).not_to be_tapped
  end

  it "does not pay when a Food is sacrificed" do
    p1.add_mana(white: 3)
    fodder = food
    attack!

    game.resolve_choice!(sacrifice: fodder)
    game.resolve_choice!(target: theirs)

    expect(p1.mana_pool.values.sum).to eq(3)
  end

  it "does nothing when the choice is declined" do
    food
    p1.add_mana(white: 3)
    attack!
    game.skip_choice!
    game.settle!

    expect(foods.count).to eq(1)
    expect(p1.mana_pool.values.sum).to eq(3)
    expect(game.choices).to be_empty
    expect([theirs, other_theirs]).to all(satisfy { !_1.tapped? })
  end

  it "offers nothing without a Food or enough mana" do
    p1.add_mana(white: 2)
    attack!

    expect(game.choices).to be_empty
    expect(theirs).not_to be_tapped
  end

  it "does not offer the payment when only a Food is available" do
    fodder = food
    attack!

    expect(game.choices.last.choices).to eq([fodder])
  end

  it "rejects a short payment" do
    p1.add_mana(white: 2)
    food
    attack!

    expect { game.resolve_choice!(pay: true) }.to raise_error(ArgumentError)
    expect(theirs).not_to be_tapped
  end

  it "only triggers when the Hobbit itself attacks" do
    food
    attack!(mine)

    expect(game.choices).to be_empty
  end
end
