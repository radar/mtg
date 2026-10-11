# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BlackcleaveCliffs do
  include_context "two player game"

  it "enters untapped with two or fewer other lands" do
    2.times { ResolvePermanent("Swamp", owner: p1) }

    expect(ResolvePermanent("Blackcleave Cliffs", owner: p1)).not_to be_tapped
  end

  it "enters tapped with three or more other lands" do
    3.times { ResolvePermanent("Swamp", owner: p1) }

    expect(ResolvePermanent("Blackcleave Cliffs", owner: p1)).to be_tapped
  end

  it "taps for black or red" do
    land = ResolvePermanent("Blackcleave Cliffs", owner: p1)

    expect(land.activated_abilities.first.choices).to contain_exactly(:black, :red)
  end
end
