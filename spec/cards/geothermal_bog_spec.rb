# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GeothermalBog do
  include_context "two player game"

  let(:bog) { ResolvePermanent("Geothermal Bog", owner: p1) }

  it "enters tapped" do
    expect(bog).to be_tapped
  end

  it "is a Swamp Mountain that taps for black or red" do
    expect(bog.type?("Swamp")).to be(true)
    expect(bog.type?("Mountain")).to be(true)
    expect(bog.activated_abilities.flat_map(&:choices)).to contain_exactly(:black, :red)
  end
end
