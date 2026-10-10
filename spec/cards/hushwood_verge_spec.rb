# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HushwoodVerge do
  include_context "two player game"

  it "taps for green mana" do
    land = ResolvePermanent("Hushwood Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "taps for white mana with a Forest" do
    ResolvePermanent("Forest", owner: p1)
    land = ResolvePermanent("Hushwood Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:white]).to eq(1)
  end

  it "taps for white mana with a Plains" do
    ResolvePermanent("Plains", owner: p1)
    land = ResolvePermanent("Hushwood Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:white]).to eq(1)
  end

  it "cannot tap for white mana without a Forest or Plains" do
    land = ResolvePermanent("Hushwood Verge", owner: p1)

    expect { p1.activate_ability(ability: land.activated_abilities.last) }.to raise_error(Magic::IllegalAction)
    expect(p1.mana_pool[:white]).to eq(0)
  end
end
