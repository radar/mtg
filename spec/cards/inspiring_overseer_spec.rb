# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InspiringOverseer do
  include_context "two player game"

  it "is a 2/1 flying Angel Cleric" do
    overseer = ResolvePermanent("Inspiring Overseer", owner: p1)

    expect([overseer.power, overseer.toughness]).to eq([2, 1])
    expect(overseer).to be_flying
  end

  it "gains you 1 life and draws a card when it enters" do
    hand_size = p1.hand.count
    ResolvePermanent("Inspiring Overseer", owner: p1)

    expect(p1.life).to eq(21)
    expect(p1.hand.count).to eq(hand_size + 1)
  end
end
