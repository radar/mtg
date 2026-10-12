# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RapidAugmenter do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:augmenter) { ResolvePermanent("Rapid Augmenter", owner: p1) }

  def token
    Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p1).resolve!.tap { game.settle! }
  end

  def cast_creature(name)
    card = Card(name, owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 5)
    p1.cast(card:) { |a| a.auto_pay_mana }
    game.stack.resolve!
    game.settle!
    game.tick!
    p1.permanents.by_name(name).first
  end

  it "is a 1/3 with haste" do
    expect([augmenter.power, augmenter.toughness]).to eq([1, 3])
    expect(augmenter).to have_keyword(:haste)
  end

  it "gives a creature with base power 1 haste until end of turn" do
    elves = ResolvePermanent("Llanowar Elves", owner: p1, summoning_sick: true)
    game.tick!

    expect(elves).to have_keyword(:haste)
  end

  it "doesn't give a base power 2 creature haste" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
    game.tick!

    expect(bears).not_to have_keyword(:haste)
  end

  it "grows and can't be blocked when a creature enters without being cast" do
    token
    game.tick!

    expect(augmenter.power).to eq(2)
    expect(augmenter).to have_keyword(:cant_be_blocked)
  end

  it "does nothing extra when the creature was cast" do
    cast_creature("Grizzly Bears")

    expect(augmenter.power).to eq(1)
    expect(augmenter).not_to have_keyword(:cant_be_blocked)
  end

  it "ignores an opponent's creature" do
    Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p2).resolve!
    game.settle!
    game.tick!

    expect(augmenter.power).to eq(1)
  end
end
