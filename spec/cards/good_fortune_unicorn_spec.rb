# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GoodFortuneUnicorn do
  include_context "two player game"

  let!(:unicorn) { ResolvePermanent("Good-Fortune Unicorn", owner: p1) }

  it "is a 2/2 Unicorn" do
    expect([unicorn.power, unicorn.toughness]).to eq([2, 2])
  end

  it "puts a +1/+1 counter on another creature you control as it enters" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(bears.power).to eq(3)
    expect(bears.counters.count).to eq(1)
    expect(unicorn.counters.count).to eq(0)
  end

  it "does nothing for the opponent's creatures" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(bears.counters.count).to eq(0)
  end

  it "does not put a counter on itself" do
    expect(unicorn.counters.count).to eq(0)
  end
end
