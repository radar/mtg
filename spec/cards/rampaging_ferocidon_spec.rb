# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RampagingFerocidon do
  include_context "two player game"

  let!(:ferocidon) { ResolvePermanent("Rampaging Ferocidon", owner: p1) }

  it "has menace" do
    expect(ferocidon).to have_keyword(:menace)
  end

  it "stops all players gaining life" do
    p1.gain_life(3)
    p2.gain_life(3)

    expect([p1.life, p2.life]).to eq([20, 20])
  end

  it "deals 1 damage to the controller of another creature that enters" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(19)
  end

  it "ignores noncreature permanents" do
    ResolvePermanent("Forest", owner: p2)
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "lets life gain resume once it leaves" do
    ferocidon.destroy!
    game.settle!
    p1.gain_life(3)

    expect(p1.life).to eq(23)
  end
end
