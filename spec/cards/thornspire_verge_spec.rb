# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThornspireVerge do
  include_context "two player game"

  it "taps for red mana" do
    land = ResolvePermanent("Thornspire Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "taps for green mana with a Mountain" do
    ResolvePermanent("Mountain", owner: p1)
    land = ResolvePermanent("Thornspire Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "taps for green mana with a Forest" do
    ResolvePermanent("Forest", owner: p1)
    land = ResolvePermanent("Thornspire Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "cannot tap for green mana without a Mountain or Forest" do
    land = ResolvePermanent("Thornspire Verge", owner: p1)

    expect { p1.activate_ability(ability: land.activated_abilities.last) }.to raise_error(Magic::IllegalAction)
    expect(p1.mana_pool[:green]).to eq(0)
  end
end
