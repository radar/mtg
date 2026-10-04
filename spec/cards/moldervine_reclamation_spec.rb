# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MoldervineReclamation do
  include_context "two player game"

  let!(:reclamation) { ResolvePermanent("Moldervine Reclamation", owner: p1) }

  it "gains 1 life and draws a card when a creature you control dies" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    hand_size = p1.hand.count

    bear.destroy!
    game.settle!

    expect(p1.life).to eq(21)
    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "does nothing when an opponent's creature dies" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    hand_size = p1.hand.count

    bear.destroy!
    game.settle!

    expect(p1.life).to eq(20)
    expect(p1.hand.count).to eq(hand_size)
  end
end
