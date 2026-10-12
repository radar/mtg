# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SeachromeCoast do
  include_context "two player game"

  it "enters untapped with two or fewer other lands" do
    2.times { ResolvePermanent("Plains", owner: p1) }
    expect(ResolvePermanent("Seachrome Coast", owner: p1)).to be_untapped
  end

  it "enters tapped with three other lands" do
    3.times { ResolvePermanent("Plains", owner: p1) }
    expect(ResolvePermanent("Seachrome Coast", owner: p1)).to be_tapped
  end

  it "taps for {W} or {U}" do
    land = ResolvePermanent("Seachrome Coast", owner: p1)
    p1.activate_ability(ability: land.activated_abilities.first) { |a| a.choose(:blue) }
    expect(p1.mana_pool[:blue]).to eq(1)
  end
end
