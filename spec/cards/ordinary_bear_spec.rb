# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OrdinaryBear do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Ordinary Bear", owner: p1) }

  it "is a 4/5 Bear with no abilities" do
    expect([bear.power, bear.toughness]).to eq([4, 5])
    expect(bear).to be_creature
    expect(bear.type?("Bear")).to be(true)
  end
end
