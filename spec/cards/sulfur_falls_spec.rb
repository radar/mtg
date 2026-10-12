# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SulfurFalls do
  include_context "two player game"

  it "enters tapped without an Island or a Mountain" do
    expect(ResolvePermanent("Sulfur Falls", owner: p1)).to be_tapped
  end

  it "enters untapped with an Island" do
    ResolvePermanent("Island", owner: p1)
    expect(ResolvePermanent("Sulfur Falls", owner: p1)).to be_untapped
  end

  it "enters untapped with a Mountain" do
    ResolvePermanent("Mountain", owner: p1)
    expect(ResolvePermanent("Sulfur Falls", owner: p1)).to be_untapped
  end

  it "taps for {U} or {R}" do
    land = ResolvePermanent("Sulfur Falls", owner: p1).tap(&:untap!)
    p1.activate_ability(ability: land.activated_abilities.first) { |a| a.choose(:red) }
    expect(p1.mana_pool[:red]).to eq(1)
  end
end
