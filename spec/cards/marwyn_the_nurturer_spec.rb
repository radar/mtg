# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MarwynTheNurturer do
  include_context "two player game"

  subject { ResolvePermanent("Marwyn, The Nurturer", owner: p1) }

  it "is a legendary 1/1 Elf Druid" do
    expect(subject.power).to eq(1)
    expect(subject.toughness).to eq(1)
    expect(subject.type?("Elf")).to be true
  end

  it "gets a +1/+1 counter whenever another Elf you control enters" do
    subject
    ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!

    expect(subject.power).to eq(2)
    expect(subject.toughness).to eq(2)
  end

  it "does not get a counter when an opponent's Elf enters" do
    subject
    ResolvePermanent("Llanowar Elves", owner: p2)

    expect(subject.power).to eq(1)
  end

  it "does not get a counter when a non-Elf creature you control enters" do
    subject
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(subject.power).to eq(1)
  end

  it "does not get a counter for itself entering" do
    expect(subject.power).to eq(1)
  end

  it "taps to add an amount of green mana equal to its power" do
    subject
    ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!

    ability = subject.activated_abilities.first
    p1.activate_ability(ability: ability)

    expect(p1.mana_pool[:green]).to eq(2)
  end
end
