# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkyrakerGiant do
  include_context "two player game"

  it "is a 4/3 Giant with reach" do
    giant = ResolvePermanent("Skyraker Giant", owner: p1)

    expect([giant.power, giant.toughness]).to eq([4, 3])
    expect(giant).to be_reach
  end
end
