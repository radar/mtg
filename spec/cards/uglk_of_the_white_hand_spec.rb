# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UglkOfTheWhiteHand do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:ugluk) { ResolvePermanent("Uglk Of The White Hand", owner: p1) }

  def plus_counters = ugluk.counters.count { _1.is_a?(Magic::Counters::Plus1Plus1) }

  it "is a 3/3 legendary Orc Soldier" do
    expect(ugluk).to be_legendary
    expect(ugluk.type?("Orc")).to eq(true)
    expect([ugluk.power, ugluk.toughness]).to eq([3, 3])
  end

  it "gets one +1/+1 counter when another creature you control dies" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    bear.destroy!
    game.settle!
    expect(plus_counters).to eq(1)
    expect([ugluk.power, ugluk.toughness]).to eq([4, 4])
  end

  it "gets two counters when the creature was a Goblin" do
    ResolvePermanent("Goblin Arsonist", owner: p1).destroy!
    game.settle!
    game.skip_choice! while game.choices.any?
    game.settle!
    expect(plus_counters).to eq(2)
  end

  it "gets two counters when the creature was an Orc" do
    ResolvePermanent("Warg Rider", owner: p1).destroy!
    game.settle!
    expect(plus_counters).to eq(2)
  end

  it "gets nothing when Uglúk himself dies" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    ugluk.destroy!
    game.settle!
    expect(other.counters.count).to eq(0)
    expect(game.choices).to be_empty
  end

  it "gets nothing when an opponent's creature dies" do
    ResolvePermanent("Warg Rider", owner: p2).destroy!
    game.settle!
    expect(plus_counters).to eq(0)
  end

  it "gets a counter for each creature when two die together" do
    a = ResolvePermanent("Grizzly Bears", owner: p1)
    b = ResolvePermanent("Warg Rider", owner: p1)
    a.destroy!
    b.destroy!
    game.settle!
    expect(plus_counters).to eq(3)
  end
end
