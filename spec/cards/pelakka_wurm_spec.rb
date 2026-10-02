# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PelakkaWurm do
  include_context "two player game"

  let!(:wurm) { ResolvePermanent("Pelakka Wurm", owner: p1) }

  it "is a 7/7 trampler" do
    expect([wurm.power, wurm.toughness]).to eq([7, 7])
    expect(wurm).to be_trample
  end

  it "gains you 7 life when it enters" do
    expect(p1.life).to eq(27)
  end

  it "draws a card when it dies" do
    hand_size = p1.hand.count
    wurm.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
  end
end
