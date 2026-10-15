# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NightshadeDryad do
  include_context "two player game"

  let!(:dryad) { ResolvePermanent("Nightshade Dryad", owner: p1) }

  it "is a 1/2 Dryad with deathtouch" do
    expect(dryad.power).to eq(1)
    expect(dryad.toughness).to eq(2)
    expect(dryad.types).to include("Dryad")
    expect(dryad).to be_deathtouch
  end

  it "taps for {C}" do
    p1.activate_ability(ability: dryad.activated_abilities.first)

    expect(dryad).to be_tapped
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "taps for one mana of any color" do
    p1.activate_ability(ability: dryad.activated_abilities.last) { _1.choose(:blue) }

    expect(dryad).to be_tapped
    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "can't produce colorless from the any-color ability" do
    expect { p1.activate_ability(ability: dryad.activated_abilities.last) { _1.choose(:colorless) } }
      .to raise_error(StandardError)
  end
end
