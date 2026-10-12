# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FateUnraveler do
  include_context "two player game"

  let!(:unraveler) { ResolvePermanent("Fate Unraveler", owner: p1) }

  it "is an enchantment creature" do
    expect(unraveler).to be_enchantment
    expect(unraveler).to be_creature
  end

  it "deals 1 damage to an opponent for each card they draw" do
    2.times { p2.draw! }
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "ignores its controller's draws" do
    p1.draw!
    game.settle!

    expect(p1.life).to eq(20)
  end
end
