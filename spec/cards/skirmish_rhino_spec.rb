# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkirmishRhino do
  include_context "two player game"

  let!(:rhino) { ResolvePermanent("Skirmish Rhino", owner: p1) }

  it "is a 3/4 with trample" do
    expect([rhino.power, rhino.toughness]).to eq([3, 4])
    expect(rhino.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
  end

  it "drains each opponent for 2 when it enters" do
    expect(p2.life).to eq(18)
    expect(p1.life).to eq(22)
  end
end
