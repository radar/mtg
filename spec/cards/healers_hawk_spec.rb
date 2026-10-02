# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HealersHawk do
  include_context "two player game"

  let!(:hawk) { ResolvePermanent("Healer's Hawk", owner: p1) }

  it "is a 1/1 Bird with flying and lifelink" do
    expect([hawk.power, hawk.toughness]).to eq([1, 1])
    expect(hawk).to be_flying
    expect(hawk).to be_lifelink
  end
end
