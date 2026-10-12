# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfBeingHunted do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:fear) { ResolvePermanent("Fear Of Being Hunted", owner: p1) }

  it "is a 4/2 haste Enchantment Creature" do
    expect([fear.power, fear.toughness]).to eq([4, 2])
    expect(fear).to be_haste
    expect(fear).to be_enchantment
  end

  it "must be blocked if able" do
    expect(fear.must_be_blocked?).to eq(true)
  end
end
