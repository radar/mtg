# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvishWarmaster do
  include_context "two player game"

  subject { ResolvePermanent("Elvish Warmaster", owner: p1) }

  it "is a 2/2 Elf Warrior" do
    expect(subject.power).to eq(2)
    expect(subject.toughness).to eq(2)
    expect(subject.type?("Elf")).to be true
  end

  it "creates a 1/1 green Elf Warrior token when another Elf you control enters" do
    subject
    ResolvePermanent("Llanowar Elves", owner: p1)

    tokens = p1.creatures.select { |c| c.name == "Elf Warrior" && c.token? }
    expect(tokens.count).to eq(1)
    expect(tokens.first.power).to eq(1)
    expect(tokens.first.toughness).to eq(1)
  end

  it "only triggers once per turn even if multiple Elves enter" do
    subject
    ResolvePermanent("Llanowar Elves", owner: p1)
    ResolvePermanent("Llanowar Elves", owner: p1)

    tokens = p1.creatures.select { |c| c.name == "Elf Warrior" && c.token? }
    expect(tokens.count).to eq(1)
  end

  it "does not trigger when an opponent's Elf enters" do
    subject
    ResolvePermanent("Llanowar Elves", owner: p2)

    tokens = p1.creatures.select { |c| c.name == "Elf Warrior" && c.token? }
    expect(tokens.count).to eq(0)
  end

  it "pumps Elves you control and grants deathtouch for {5}{G}{G}" do
    subject
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 7)

    ability = subject.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.pay_mana(generic: { green: 5 }, green: 2) }
    game.stack.resolve!
    game.tick!

    expect(subject.power).to eq(4)
    expect(subject.toughness).to eq(4)
    expect(subject.deathtouch?).to be true
    expect(elf.power).to eq(3)
    expect(elf.deathtouch?).to be true
    expect(bear.deathtouch?).to be false
  end
end
