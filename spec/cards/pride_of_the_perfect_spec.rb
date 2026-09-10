# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PrideOfThePerfect do
  include_context "two player game"

  let!(:pride) { ResolvePermanent("Pride Of The Perfect", owner: p1) }

  it "gives Elves you control +2/+0" do
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!

    expect(elf.power).to eq(3)
    expect(elf.toughness).to eq(1)
  end

  it "does not affect non-Elf creatures you control" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(bear.power).to eq(2)
    expect(bear.toughness).to eq(2)
  end

  it "does not affect an opponent's Elves" do
    opponents_elf = ResolvePermanent("Llanowar Elves", owner: p2)
    game.tick!

    expect(opponents_elf.power).to eq(1)
    expect(opponents_elf.toughness).to eq(1)
  end
end
