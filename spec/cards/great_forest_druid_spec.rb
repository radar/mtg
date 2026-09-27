# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GreatForestDruid do
  include_context "two player game"

  let!(:druid) { ResolvePermanent("Great Forest Druid", owner: p1) }

  it "is a 0/4 treefolk druid" do
    expect(druid.card.types).to include("Treefolk", "Druid")
    expect(druid.power).to eq(0)
    expect(druid.toughness).to eq(4)
  end

  it "taps for one mana of any color" do
    p1.activate_ability(ability: druid.activated_abilities.first) { _1.choose(:red) }

    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "can choose blue instead" do
    p1.activate_ability(ability: druid.activated_abilities.first) { _1.choose(:blue) }

    expect(p1.mana_pool[:blue]).to eq(1)
  end
end
