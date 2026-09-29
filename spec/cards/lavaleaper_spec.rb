# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Lavaleaper do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:lavaleaper) { ResolvePermanent("Lavaleaper", owner: p1) }

  it "gives all creatures haste, yours and theirs" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2, summoning_sick: true)
    mine = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
    game.tick!

    expect([theirs, mine, lavaleaper]).to all(be_haste)
  end

  it "adds another mana of the same type when a player taps a basic land for mana" do
    forest = ResolvePermanent("Forest", owner: p1)
    p1.activate_ability(ability: forest.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(2)
  end

  it "does the same for an opponent's basic land" do
    go_to_main_phase_for!(p2)
    island = ResolvePermanent("Island", owner: p2)
    p2.activate_ability(ability: island.activated_abilities.first) { _1.choose(:blue) }

    expect(p2.mana_pool[:blue]).to eq(2)
  end

  it "does not add mana for a nonbasic land" do
    land = ResolvePermanent("Botanical Plaza", owner: p1)
    land.untap!
    ability = land.activated_abilities.first
    p1.activate_ability(ability:) { _1.choose(ability.choices.first) }

    expect(p1.mana_pool.values.sum).to eq(1)
  end
end
