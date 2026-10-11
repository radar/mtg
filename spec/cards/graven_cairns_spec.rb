# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GravenCairns do
  include_context "two player game"

  let(:cairns) { ResolvePermanent("Graven Cairns", owner: p1) }

  it "taps for {C}" do
    p1.activate_ability(ability: cairns.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "filters {B/R} into {B}{B}, {B}{R} or {R}{R}" do
    p1.add_mana(red: 1)
    p1.activate_ability(ability: cairns.activated_abilities.last) do |action|
      action.pay_mana(red: 1)
      action.choose(:black_red)
    end

    expect(p1.mana_pool[:black]).to eq(1)
    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "can make {R}{R}" do
    p1.add_mana(black: 1)
    p1.activate_ability(ability: cairns.activated_abilities.last) do |action|
      action.pay_mana(black: 1)
      action.choose(:red_red)
    end

    expect(p1.mana_pool[:red]).to eq(2)
  end
end
