# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PhyrexianTower do
  include_context "two player game"

  let!(:tower) { ResolvePermanent("Phyrexian Tower", owner: p1) }

  it "is a legendary land" do
    expect(tower).to be_legendary
    expect(tower).to be_land
  end

  it "taps for {C}" do
    p1.activate_ability(ability: tower.activated_abilities.first)

    expect(tower).to be_tapped
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "taps and sacrifices a creature for {B}{B}" do
    elves = ResolvePermanent("Wood Elves", owner: p1)
    p1.activate_ability(ability: tower.activated_abilities.last) { |a| a.pay_sacrifice(elves) }

    expect(tower).to be_tapped
    expect(p1.mana_pool[:black]).to eq(2)
    expect(elves.card.zone).to be_graveyard
  end

  it "does not make {B}{B} from the colorless ability" do
    p1.activate_ability(ability: tower.activated_abilities.first)

    expect(p1.mana_pool[:black]).to eq(0)
  end
end
