# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FireElemental do
  include_context "two player game"

  it "is a 5/4 Elemental" do
    elemental = ResolvePermanent("Fire Elemental", owner: p1)

    expect([elemental.power, elemental.toughness]).to eq([5, 4])
  end
end
