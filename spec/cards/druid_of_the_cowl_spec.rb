# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DruidOfTheCowl do
  include_context "two player game"

  let!(:druid) { ResolvePermanent("Druid Of The Cowl", owner: p1) }

  it "is a 1/3 Elf Druid" do
    expect([druid.power, druid.toughness]).to eq([1, 3])
  end

  it "taps for {G}" do
    p1.activate_ability(ability: druid.activated_abilities.first)

    expect(druid).to be_tapped
    expect(p1.mana_pool[:green]).to eq(1)
  end
end
