# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CascadeBluffs do
  include_context "two player game"

  let!(:land) { ResolvePermanent("Cascade Bluffs", owner: p1) }

  it "taps for {C}" do
    p1.activate_ability(ability: land.activated_abilities.first)
    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "pays {U} or {R} and taps to add {U}{U}" do
    p1.add_mana(red: 1)
    p1.activate_ability(ability: land.activated_abilities.last) do |a|
      a.choose(:blue_blue)
      a.pay_mana(red: 1)
    end

    expect(land).to be_tapped
    expect(p1.mana_pool[:blue]).to eq(2)
    expect(p1.mana_pool[:red]).to eq(0)
  end

  it "adds {U}{R}" do
    p1.add_mana(blue: 1)
    p1.activate_ability(ability: land.activated_abilities.last) do |a|
      a.choose(:blue_red)
      a.pay_mana(blue: 1)
    end

    expect([p1.mana_pool[:blue], p1.mana_pool[:red]]).to eq([1, 1])
  end

  it "cannot be paid for with mana of another colour" do
    p1.add_mana(green: 1)

    expect do
      p1.activate_ability(ability: land.activated_abilities.last) do |a|
        a.choose(:red_red)
        a.pay_mana(green: 1)
      end
    end.to raise_error(StandardError)
  end
end
