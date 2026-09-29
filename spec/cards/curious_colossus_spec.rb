# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CuriousColossus do
  include_context "two player game"

  it "is a 7/7 Giant Warrior" do
    colossus = ResolvePermanent("Curious Colossus", owner: p1, cast: false)

    expect([colossus.power, colossus.toughness]).to eq([7, 7])
  end

  it "makes each creature target opponent controls lose all abilities, become a Coward and be 1/1" do
    flyer = ResolvePermanent("Shinestriker", owner: p2)
    courser = ResolvePermanent("Courser Of Kruphix", owner: p2)
    ResolvePermanent("Curious Colossus", owner: p1)
    game.tick!

    [flyer, courser].each do |creature|
      expect([creature.power, creature.toughness]).to eq([1, 1])
      expect(creature.type?("Coward")).to be(true)
    end
    expect(flyer).not_to be_flying
    expect(flyer.type?("Elemental")).to be(true) # a Coward in addition to its other types
  end

  it "doesn't affect your own creatures" do
    mine = ResolvePermanent("Courser Of Kruphix", owner: p1)
    ResolvePermanent("Curious Colossus", owner: p1)
    game.tick!

    expect(mine.power).to eq(2)
  end

  it "lasts past the end of turn" do
    theirs = ResolvePermanent("Courser Of Kruphix", owner: p2)
    ResolvePermanent("Curious Colossus", owner: p1)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([theirs.power, theirs.toughness]).to eq([1, 1])
    expect(theirs.type?("Coward")).to be(true)
  end

  it "doesn't affect creatures that enter later" do
    ResolvePermanent("Curious Colossus", owner: p1)
    later = ResolvePermanent("Courser Of Kruphix", owner: p2)
    game.tick!

    expect(later.power).to eq(2)
  end
end
