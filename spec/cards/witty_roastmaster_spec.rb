# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WittyRoastmaster do
  include_context "two player game"

  let!(:roastmaster) { ResolvePermanent("Witty Roastmaster", owner: p1) }

  it "is a 3/2" do
    expect([roastmaster.power, roastmaster.toughness]).to eq([3, 2])
  end

  it "deals 1 damage to each opponent when another creature enters under your control" do
    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.to change { p2.life }.by(-1)
  end

  it "doesn't trigger for an opponent's creature" do
    expect { ResolvePermanent("Grizzly Bears", owner: p2) }.not_to change { p2.life }
  end
end
