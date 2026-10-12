# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TunnelSurveyor do
  include_context "two player game"

  def glimmers = p1.creatures.select { _1.type?("Glimmer") }

  it "is a 2/2 Human Detective" do
    surveyor = ResolvePermanent("Tunnel Surveyor", owner: p1)

    expect(surveyor.power).to eq(2)
    expect(surveyor.toughness).to eq(2)
    expect(surveyor.type?("Detective")).to be(true)
  end

  it "creates a 1/1 white Glimmer enchantment creature token when it enters" do
    ResolvePermanent("Tunnel Surveyor", owner: p1)

    expect(glimmers.size).to eq(1)
    token = glimmers.first
    expect(token.power).to eq(1)
    expect(token.toughness).to eq(1)
    expect(token.enchantment?).to be(true)
    expect(token.colors).to eq([:white])
  end
end
