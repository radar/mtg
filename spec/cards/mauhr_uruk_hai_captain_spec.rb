# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MauhrUrukHaiCaptain do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:mauhur) { ResolvePermanent("Mauhr Uruk Hai Captain", owner: p1) }

  def plus_counters(permanent) = permanent.counters.count { _1.is_a?(Magic::Counters::Plus1Plus1) }

  it "is a 2/2 legendary Orc Soldier with menace" do
    expect(mauhur).to be_legendary
    expect(mauhur.type?("Orc")).to eq(true)
    expect([mauhur.power, mauhur.toughness]).to eq([2, 2])
    expect(mauhur.has_keyword?(Magic::Cards::Keywords::MENACE)).to eq(true)
  end

  it "adds one more +1/+1 counter on a Goblin you control" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    goblin.add_counter("+1/+1", amount: 1)
    expect(plus_counters(goblin)).to eq(2)
  end

  it "adds one more +1/+1 counter on an Orc you control, including itself" do
    orc = ResolvePermanent("Warg Rider", owner: p1)
    orc.add_counter("+1/+1", amount: 2)
    mauhur.add_counter("+1/+1", amount: 1)
    expect(plus_counters(orc)).to eq(3)
    expect(plus_counters(mauhur)).to eq(2)
  end

  it "adds one more +1/+1 counter on an Army you control" do
    army = Magic::Amass.call(source: mauhur, controller: p1, amount: 1, subtype: "Orc")
    game.settle!
    expect(plus_counters(army)).to eq(2)
  end

  it "does not change counters on other creature types" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    bear.add_counter("+1/+1", amount: 1)
    expect(plus_counters(bear)).to eq(1)
  end

  it "does not change counters on an opponent's Goblin or Orc" do
    theirs = ResolvePermanent("Warg Rider", owner: p2)
    theirs.add_counter("+1/+1", amount: 1)
    expect(plus_counters(theirs)).to eq(1)
  end

  it "does not change other kinds of counters" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    goblin.add_counter("burden", amount: 1)
    expect(plus_counters(goblin)).to eq(0)
    expect(goblin.counters.count).to eq(1)
  end

  it "stacks additively with a second copy you control" do
    ResolvePermanent("Mauhr Uruk Hai Captain", owner: p1)
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    goblin.add_counter("+1/+1", amount: 1)
    expect(plus_counters(goblin)).to eq(3)
  end

  it "does not help your creatures when the Captain is an opponent's" do
    theirs = ResolvePermanent("Mauhr Uruk Hai Captain", owner: p2)
    mine = ResolvePermanent("Goblin Arsonist", owner: p1)
    mauhur.destroy!
    game.settle!
    mine.add_counter("+1/+1", amount: 1)
    expect(plus_counters(mine)).to eq(1)
    expect(plus_counters(theirs)).to eq(0)
  end
end
