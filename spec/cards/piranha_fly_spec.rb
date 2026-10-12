# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PiranhaFly do
  include_context "two player game"

  subject(:fly) { ResolvePermanent("Piranha Fly", owner: p1) }

  it "is a 2/1 flyer" do
    expect([fly.power, fly.toughness]).to eq([2, 1])
    expect(fly).to be_flying
  end

  it "enters tapped" do
    expect(fly).to be_tapped
  end
end
