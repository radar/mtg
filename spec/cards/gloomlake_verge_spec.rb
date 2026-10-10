# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GloomlakeVerge do
  include_context "two player game"

  it "taps for blue mana" do
    land = ResolvePermanent("Gloomlake Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first)

    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "taps for black mana with an Island" do
    ResolvePermanent("Island", owner: p1)
    land = ResolvePermanent("Gloomlake Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "taps for black mana with a Swamp" do
    ResolvePermanent("Swamp", owner: p1)
    land = ResolvePermanent("Gloomlake Verge", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.last)

    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "cannot tap for black mana without an Island or Swamp" do
    land = ResolvePermanent("Gloomlake Verge", owner: p1)

    expect { p1.activate_ability(ability: land.activated_abilities.last) }.to raise_error(Magic::IllegalAction)
    expect(p1.mana_pool[:black]).to eq(0)
  end
end
