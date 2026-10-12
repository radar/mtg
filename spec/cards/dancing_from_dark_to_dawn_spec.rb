# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DancingFromDarkToDawn do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:dancing) { ResolvePermanent("Dancing From Dark To Dawn", owner: p1) }
  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }

  def bears_tokens = p1.creatures.select { _1.token? && _1.type?("Bear") }

  it "puts counters equal to the creature spell's mana value on a creature you control" do
    p1.add_mana(green: 2)
    p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
    game.resolve_choice!(target: elves) if game.choices.any?
    game.settle!
    game.tick!

    expect([elves.power, elves.toughness]).to eq([3, 3])
  end

  it "doesn't trigger for noncreature spells" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!
    game.tick!

    expect(game.choices).to be_empty
    expect([elves.power, elves.toughness]).to eq([1, 1])
  end

  it "creates a 2/2 green Bear when a land enters under your control" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!

    expect(bears_tokens.size).to eq(1)
    expect([bears_tokens.first.power, bears_tokens.first.toughness]).to eq([2, 2])
  end
end
