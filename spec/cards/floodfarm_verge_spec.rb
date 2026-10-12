# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FloodfarmVerge do
  include_context "two player game"

  it "taps for white mana" do
    land = ResolvePermanent("Floodfarm Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:white]).to eq(1)
  end

  it "taps for blue mana with a Plains" do
    ResolvePermanent("Plains", owner: p1)
    land = ResolvePermanent("Floodfarm Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "taps for blue mana with an Island" do
    ResolvePermanent("Island", owner: p1)
    land = ResolvePermanent("Floodfarm Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "cannot tap for blue mana without a Plains or Island" do
    land = ResolvePermanent("Floodfarm Verge", owner: p1)

    expect { p1.activate_ability(ability: land.activated_abilities.last) }.to raise_error(Magic::IllegalAction)
    expect(p1.mana_pool[:blue]).to eq(0)
  end
end
