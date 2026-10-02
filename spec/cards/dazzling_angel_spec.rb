# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DazzlingAngel do
  include_context "two player game"

  let!(:angel) { ResolvePermanent("Dazzling Angel", owner: p1) }

  it "is a 2/3 flyer" do
    expect([angel.power, angel.toughness]).to eq([2, 3])
    expect(angel).to be_flying
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
