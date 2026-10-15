# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HarbingerOfTheSeas do
  include_context "two player game"

  it "is a 2/2 Merfolk Wizard" do
    harbinger = ResolvePermanent("Harbinger Of The Seas", owner: p1)
    expect(harbinger.power).to eq(2)
    expect(harbinger.toughness).to eq(2)
  end

  it "makes nonbasic lands of either player Islands" do
    ResolvePermanent("Harbinger Of The Seas", owner: p1)
    mine = ResolvePermanent("Urzas Cave", owner: p1)
    theirs = ResolvePermanent("Urzas Cave", owner: p2)
    game.tick!
    expect(mine.type?("Island")).to eq(true)
    expect(theirs.type?("Island")).to eq(true)
  end

  it "makes a nonbasic land tap for {U} and lose its own abilities" do
    ResolvePermanent("Harbinger Of The Seas", owner: p1)
    cave = ResolvePermanent("Urzas Cave", owner: p1)
    game.tick!
    expect(cave.activated_abilities.map(&:class)).to eq([Magic::Types::Lands::Island::ManaAbility])
    p1.activate_ability(ability: cave.activated_abilities.first)
    expect(p1.mana_pool[:blue]).to eq(1)
    expect(p1.mana_pool[:colorless]).to eq(0)
  end

  it "removes old land subtypes" do
    ResolvePermanent("Harbinger Of The Seas", owner: p1)
    gate = ResolvePermanent("Selesnya Guildgate", owner: p1)
    game.tick!
    expect(gate.type?(Magic::Types::Lands::Gate)).to eq(false)
    expect(gate.type?("Island")).to eq(true)
  end

  it "stops when Harbinger leaves the battlefield" do
    harbinger = ResolvePermanent("Harbinger Of The Seas", owner: p1)
    cave = ResolvePermanent("Urzas Cave", owner: p1)
    game.tick!
    harbinger.destroy!
    game.settle!
    expect(cave.type?("Island")).to eq(false)
    expect(cave.activated_abilities.map(&:class)).to eq([Magic::Cards::UrzasCave::ManaAbility, Magic::Cards::UrzasCave::SearchAbility])
  end

  it "does not affect basic lands" do
    ResolvePermanent("Harbinger Of The Seas", owner: p1)
    mountain = ResolvePermanent("Mountain", owner: p1)
    game.tick!
    expect(mountain.type?("Island")).to eq(false)
  end
end
