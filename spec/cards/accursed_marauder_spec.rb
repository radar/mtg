# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AccursedMarauder do
  include_context "two player game"

  let(:card) { Card("Accursed Marauder", owner: p1) }

  def cast_marauder
    go_to_main_phase!
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  def names(player) = player.creatures.map(&:name)

  it "is a 2/1" do
    marauder = ResolvePermanent("Accursed Marauder", owner: p1)
    expect([marauder.power, marauder.toughness]).to eq([2, 1])
  end

  it "makes each player sacrifice a nontoken creature of their choice" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Llanowar Elves", owner: p2)
    cast_marauder
    expect(game.choices.last.chooser).to eq(p1)
    expect(game.choices.last.choices).to contain_exactly(bear, p1.creatures.find { _1.name == "Accursed Marauder" })
    game.resolve_choice!(target: bear)
    game.settle!
    expect(game.choices.last.chooser).to eq(p2)
    elves = p2.creatures.find { _1.name == "Llanowar Elves" }
    game.resolve_choice!(target: elves)
    game.settle!
    expect(names(p1)).to eq(["Accursed Marauder"])
    expect(names(p2)).to eq(["Grizzly Bears"])
  end

  it "can make you sacrifice the Marauder itself" do
    cast_marauder
    expect(names(p1)).to be_empty
  end

  it "cannot sacrifice tokens, and a player with only tokens sacrifices nothing" do
    token = Magic::Tokens::HumanSoldier.new(game: game, owner: p2).resolve!
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_marauder
    expect(game.choices.last.choices).not_to include(token)
    game.resolve_choice!(target: bear)
    game.settle!
    expect(game.choices).to be_empty
    expect(p2.creatures).to include(token)
  end

  it "sacrifices the first option for each player when the choice is skipped" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Llanowar Elves", owner: p2)
    cast_marauder
    game.skip_choice!
    game.settle!
    game.skip_choice! if game.choices.any?
    game.settle!
    expect(p1.creatures.count).to eq(1)
    expect(p2.creatures.count).to eq(1)
  end
end
