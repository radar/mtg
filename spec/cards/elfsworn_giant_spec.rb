# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElfswornGiant do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:giant) { ResolvePermanent("Elfsworn Giant", owner: p1) }

  it "is a 5/3 with reach" do
    expect([giant.power, giant.toughness]).to eq([5, 3])
    expect(giant).to be_reach
  end

  it "creates a 1/1 green Elf Warrior token when a land enters under your control" do
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!
    elf = p1.creatures.find { _1.name == "Elf Warrior" }

    expect(elf).not_to be_nil
    expect([elf.power, elf.toughness]).to eq([1, 1])
  end

  it "doesn't trigger on an opponent's land" do
    go_to_main_phase_for!(p2)
    p2.play_land(land: Card("Mountain", owner: p2))
    game.settle!

    expect(p1.creatures.select { _1.name == "Elf Warrior" }).to be_empty
  end
end
