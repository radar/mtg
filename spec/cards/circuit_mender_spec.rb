# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CircuitMender do
  include_context "two player game"

  it "is a 2/3 artifact creature" do
    mender = ResolvePermanent("Circuit Mender", owner: p1)
    expect([mender.power, mender.toughness]).to eq([2, 3])
    expect(mender.type?("Artifact")).to be true
  end

  it "gains 2 life when it enters" do
    expect { ResolvePermanent("Circuit Mender", owner: p1) }.to change { p1.life }.by(2)
  end

  it "draws a card when it leaves the battlefield" do
    mender = ResolvePermanent("Circuit Mender", owner: p1)

    expect do
      mender.destroy!
      game.settle!
    end.to change { p1.hand.count }.by(1)
  end
end
