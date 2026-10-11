# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DragonskullSummit do
  include_context "two player game"

  it "enters untapped if you control a Swamp" do
    ResolvePermanent("Swamp", owner: p1)

    expect(ResolvePermanent("Dragonskull Summit", owner: p1)).not_to be_tapped
  end

  it "enters untapped if you control a Mountain" do
    ResolvePermanent("Mountain", owner: p1)

    expect(ResolvePermanent("Dragonskull Summit", owner: p1)).not_to be_tapped
  end

  it "enters tapped otherwise" do
    ResolvePermanent("Forest", owner: p1)

    expect(ResolvePermanent("Dragonskull Summit", owner: p1)).to be_tapped
  end

  it "taps for black or red" do
    land = ResolvePermanent("Dragonskull Summit", owner: p1)

    expect(land.activated_abilities.first.choices).to contain_exactly(:black, :red)
  end
end
