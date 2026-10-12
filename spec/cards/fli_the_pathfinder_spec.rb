# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FliThePathfinder do
  include_context "two player game"

  def dwarf_tokens = p1.creatures.select { _1.token? && _1.type?("Dwarf") }

  let!(:fili) { ResolvePermanent("Fíli The Pathfinder", owner: p1) }

  it "is a 2/2 legendary Dwarf Scout" do
    game.tick!
    expect(fili.type?("Dwarf")).to eq(true)
    expect([fili.power, fili.toughness]).to eq([2, 2])
  end

  it "creates a 2/2 red Dwarf token when it enters" do
    expect(dwarf_tokens.count).to eq(1)
    expect(dwarf_tokens.first.colors).to eq([:red])
  end

  it "creates a Dwarf token when another nontoken Dwarf you control enters, but not for the token itself" do
    ResolvePermanent("Dwarven Provisioner", owner: p1)
    expect(dwarf_tokens.count).to eq(2)
  end

  it "doesn't trigger for an opponent's Dwarf or a non-Dwarf" do
    ResolvePermanent("Dwarven Provisioner", owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p1)
    expect(dwarf_tokens.count).to eq(1)
  end

  it "gives creatures you control +1/+1 once you have an enduring story" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    # Fíli, the Dwarf token and the Bears: only one legendary so far.
    expect(bears.power).to eq(2)
    ResolvePermanent("Short Sword", owner: p1)
    ResolvePermanent("Short Sword", owner: p1)
    game.tick!
    expect(Magic::Storied.enduring_story?(p1)).to eq(true)
    game.tick!
    expect([bears.power, bears.toughness]).to eq([3, 3])
  end
end
