# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HinterlandSanctifier do
  include_context "two player game"

  let!(:sanctifier) { ResolvePermanent("Hinterland Sanctifier", owner: p1) }

  it "is a 1/2" do
    expect([sanctifier.power, sanctifier.toughness]).to eq([1, 2])
  end

  it "gains you 1 life when another creature enters under your control" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(p1.life).to eq(21)
  end

  it "doesn't trigger for an opponent's creature" do
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect(p1.life).to eq(20)
  end
end
