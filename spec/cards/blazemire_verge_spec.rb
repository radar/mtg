# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BlazemireVerge do
  include_context "two player game"

  it "taps for black mana" do
    land = ResolvePermanent("Blazemire Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "taps for red mana with a Mountain" do
    ResolvePermanent("Mountain", owner: p1)
    land = ResolvePermanent("Blazemire Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "taps for red mana with a Swamp" do
    ResolvePermanent("Swamp", owner: p1)
    land = ResolvePermanent("Blazemire Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "cannot tap for red mana without a Swamp or Mountain" do
    land = ResolvePermanent("Blazemire Verge", owner: p1)

    expect { p1.activate_ability(ability: land.activated_abilities.last) }.to raise_error(Magic::IllegalAction)
    expect(p1.mana_pool[:red]).to eq(0)
  end
end
