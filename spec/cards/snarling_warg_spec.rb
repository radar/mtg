# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SnarlingWarg do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:warg) { ResolvePermanent("Snarling Warg", owner: p1) }

  it "is a 3/4 Wolf with menace" do
    expect([warg.power, warg.toughness]).to eq([3, 4])
    expect(warg.has_keyword?(Magic::Cards::Keywords::MENACE)).to eq(true)
  end

  it "gets +1/+0 while you control a Goblin" do
    ResolvePermanent("Goblin Arsonist", owner: p1)
    game.tick!
    expect([warg.power, warg.toughness]).to eq([4, 4])
  end

  it "gets +1/+0 while you control an Orc" do
    ResolvePermanent("Warg Rider", owner: p1)
    game.tick!
    expect([warg.power, warg.toughness]).to eq([4, 4])
  end

  it "does not stack for two Goblins or Orcs" do
    ResolvePermanent("Goblin Arsonist", owner: p1)
    ResolvePermanent("Warg Rider", owner: p1)
    game.tick!
    expect(warg.power).to eq(4)
  end

  it "gets no bonus from a Goblin or Orc an opponent controls" do
    ResolvePermanent("Warg Rider", owner: p2)
    game.tick!
    expect(warg.power).to eq(3)
  end

  it "gets no bonus from other creature types" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    expect(warg.power).to eq(3)
  end

  it "loses the bonus when the Goblin or Orc leaves" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    game.tick!
    expect(warg.power).to eq(4)
    goblin.destroy!
    game.settle!
    game.tick!
    expect(warg.power).to eq(3)
  end
end
