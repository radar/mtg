# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GarruksGorehorn do
  include_context "two player game"

  it "is a 7/3 Beast" do
    gorehorn = ResolvePermanent("Garruks Gorehorn", owner: p1)

    expect([gorehorn.power, gorehorn.toughness]).to eq([7, 3])
    expect(gorehorn.type?("Beast")).to eq(true)
  end
end
