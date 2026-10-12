# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlacialFortress do
  include_context "two player game"

  it "enters tapped without a Plains or an Island" do
    expect(ResolvePermanent("Glacial Fortress", owner: p1)).to be_tapped
  end

  it "enters untapped with a Plains" do
    ResolvePermanent("Plains", owner: p1)
    expect(ResolvePermanent("Glacial Fortress", owner: p1)).to be_untapped
  end

  it "enters untapped with an Island" do
    ResolvePermanent("Island", owner: p1)
    expect(ResolvePermanent("Glacial Fortress", owner: p1)).to be_untapped
  end

  it "taps for {W} or {U}" do
    land = ResolvePermanent("Glacial Fortress", owner: p1).tap(&:untap!)
    p1.activate_ability(ability: land.activated_abilities.first) { |a| a.choose(:blue) }
    expect(p1.mana_pool[:blue]).to eq(1)
  end
end
