# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::QuakestriderCeratops do
  include_context "two player game"

  it "is a 12/8 Dinosaur" do
    ceratops = ResolvePermanent("Quakestrider Ceratops", owner: p1)

    expect([ceratops.power, ceratops.toughness]).to eq([12, 8])
  end
end
