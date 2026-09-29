# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TendTheSprigs do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Tend The Sprigs", owner: p1) }

  def cast_and_search
    p1.library.add(Card("Forest", owner: p1))
    p1.hand.add(card)
    p1.add_mana(green: 3)
    p1.cast(card:) { _1.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!
    forest = p1.library.basic_lands.first
    game.resolve_choice!(targets: [forest])
    forest
  end

  it "puts a basic land onto the battlefield tapped" do
    forest = cast_and_search
    land = p1.lands.find { _1.card == forest }

    expect(land).to be_tapped
  end

  it "creates no Treefolk with fewer than seven lands and/or Treefolk" do
    cast_and_search

    expect(p1.creatures).to be_empty
  end

  it "creates a 3/4 green Treefolk with reach when you control seven or more lands and/or Treefolk" do
    6.times { ResolvePermanent("Forest", owner: p1) }
    cast_and_search
    treefolk = p1.creatures.find { _1.name == "Treefolk" }

    expect([treefolk.power, treefolk.toughness, treefolk.colors]).to eq([3, 4, [:green]])
    expect(treefolk).to be_reach
  end

it "counts Treefolk towards the seven" do
  5.times { ResolvePermanent("Forest", owner: p1) }
  ResolvePermanent("Doran, Besieged By Time", owner: p1) # a Treefolk
  cast_and_search # five Forests + the fetched land + Doran = seven

  expect(p1.creatures.count { _1.name == "Treefolk" }).to eq(1)
end
end
