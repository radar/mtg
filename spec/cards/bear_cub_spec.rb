# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BearCub do
  include_context "two player game"

  let!(:cub) { ResolvePermanent("Bear Cub", owner: p1) }

  it "is a 2/2 Bear" do
    expect([cub.power, cub.toughness]).to eq([2, 2])
    expect(cub).to be_type("Bear")
  end
end
