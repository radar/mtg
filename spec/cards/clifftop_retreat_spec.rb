# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ClifftopRetreat do
  include_context "two player game"

  it "enters tapped without a Mountain or a Plains" do
    expect(ResolvePermanent("Clifftop Retreat", owner: p1)).to be_tapped
  end

  it "enters untapped with a Mountain" do
    ResolvePermanent("Mountain", owner: p1)
    expect(ResolvePermanent("Clifftop Retreat", owner: p1)).to be_untapped
  end

  it "enters untapped with a Plains" do
    ResolvePermanent("Plains", owner: p1)
    expect(ResolvePermanent("Clifftop Retreat", owner: p1)).to be_untapped
  end

  it "taps for {R} or {W}" do
    land = ResolvePermanent("Clifftop Retreat", owner: p1).tap(&:untap!)
    p1.activate_ability(ability: land.activated_abilities.first) { |a| a.choose(:red) }
    expect(p1.mana_pool[:red]).to eq(1)
  end
end
