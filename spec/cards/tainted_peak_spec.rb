# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TaintedPeak do
  include_context "two player game"

  let!(:peak) { ResolvePermanent("Tainted Peak", owner: p1) }

  it "taps for {C}" do
    p1.activate_ability(ability: peak.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "taps for {B} or {R} only if you control a Swamp" do
    colored = peak.activated_abilities.last
    expect(colored).not_to be_requirements_met

    ResolvePermanent("Swamp", owner: p1)
    expect(colored).to be_requirements_met
    expect(colored.choices).to contain_exactly(:black, :red)
  end
end
