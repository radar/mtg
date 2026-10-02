# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Cloudblazer do
  include_context "two player game"

  it "is a 2/2 flyer" do
    blazer = ResolvePermanent("Cloudblazer", owner: p1)

    expect([blazer.power, blazer.toughness]).to eq([2, 2])
    expect(blazer).to be_flying
  end

  it "gains you 2 life and draws two cards when it enters" do
    hand_size = p1.hand.count
    ResolvePermanent("Cloudblazer", owner: p1)

    expect(p1.life).to eq(22)
    expect(p1.hand.count).to eq(hand_size + 2)
  end
end
