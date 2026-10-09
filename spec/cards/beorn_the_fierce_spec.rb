# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BeornTheFierce do
  include_context "two player game"

  let!(:beorn) { ResolvePermanent("Beorn The Fierce", owner: p1) }

  def begin_combat
    go_to_main_phase!
    current_turn.beginning_of_combat!
    game.settle!
  end

  it "is a 6/6 legendary Bear with trample" do
    expect([beorn.power, beorn.toughness]).to eq([6, 6])
    expect(beorn.card.types).to include("Bear", "Shapeshifter", "Warrior")
    expect(beorn.trample?).to be(true)
  end

  it "gives other Bears you control +2/+2" do
    elves = ResolvePermanent("Wood Elves", owner: p1)
    elves.add_types("Bear", until_eot: false)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    theirs.add_types("Bear", until_eot: false)
    game.tick!

    expect([elves.power, elves.toughness]).to eq([3, 3])
    expect([theirs.power, theirs.toughness]).to eq([2, 2])
    expect([beorn.power, beorn.toughness]).to eq([6, 6])
  end

  it "puts a trample counter on a creature and makes it a Bear at the beginning of combat" do
    elves = ResolvePermanent("Wood Elves", owner: p1)
    begin_combat
    game.resolve_choice!(target: elves)
    game.tick!

    expect(elves.trample?).to be(true)
    expect(elves.type?("Bear")).to be(true)
    expect([elves.power, elves.toughness]).to eq([3, 3])
  end

  it "draws two cards if you control three or more Bears" do
    ResolvePermanent("Grizzly Bears", owner: p1).add_types("Bear", until_eot: false)
    elves = ResolvePermanent("Wood Elves", owner: p1)
    begin_combat
    hand = p1.hand.count
    game.resolve_choice!(target: elves)

    expect(p1.hand.count).to eq(hand + 2)
  end

  it "doesn't draw with fewer than three Bears" do
    elves = ResolvePermanent("Wood Elves", owner: p1)
    begin_combat
    hand = p1.hand.count
    game.resolve_choice!(target: elves)

    expect(p1.hand.count).to eq(hand)
  end

  it "still draws two if you choose no target and control three Bears" do
    ResolvePermanent("Grizzly Bears", owner: p1).add_types("Bear", until_eot: false)
    ResolvePermanent("Wood Elves", owner: p1).add_types("Bear", until_eot: false)
    begin_combat
    hand = p1.hand.count
    game.skip_choice!

    expect(p1.hand.count).to eq(hand + 2)
  end

  it "doesn't trigger on the opponent's turn" do
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    game.settle!

    expect(game.choices).to be_empty
  end
end
