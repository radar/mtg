# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LargeBear do
  include_context "two player game"

  subject(:bear) { ResolvePermanent("Large Bear", owner: p1) }

  it "is a 5/5 Bear with reach, trample and haste" do
    expect(bear.power).to eq(5)
    expect(bear.toughness).to eq(5)
    expect(bear.type?("Bear")).to eq(true)
    expect(bear.reach?).to eq(true)
    expect(bear.trample?).to eq(true)
    expect(bear.haste?).to eq(true)
  end
end
