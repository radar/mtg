# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ImperiousPerfect do
  include_context "two player game"

  let!(:perfect) { ResolvePermanent("Imperious Perfect", owner: p1) }

  it "is a 2/2 Elf Warrior" do
    expect(perfect.power).to eq(2)
    expect(perfect.toughness).to eq(2)
    expect(perfect.type?("Elf")).to be true
  end

  it "gives other Elves you control +1/+1" do
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!

    expect(elf.power).to eq(2)
    expect(elf.toughness).to eq(2)
  end

  it "does not buff itself" do
    game.tick!
    expect(perfect.power).to eq(2)
    expect(perfect.toughness).to eq(2)
  end

  it "does not buff an opponent's Elves" do
    opponents_elf = ResolvePermanent("Llanowar Elves", owner: p2)
    game.tick!

    expect(opponents_elf.power).to eq(1)
    expect(opponents_elf.toughness).to eq(1)
  end

  it "creates a 1/1 green Elf Warrior token for {G}, {T}" do
    p1.add_mana(green: 1)
    p1.activate_ability(ability: perfect.activated_abilities.first) { |a| a.pay_mana(green: 1) }
    game.stack.resolve!

    tokens = p1.creatures.select { |c| c.name == "Elf Warrior" && c.token? }
    expect(tokens.count).to eq(1)

    token = tokens.first
    game.tick!
    expect(token.power).to eq(2)
    expect(token.toughness).to eq(2)
  end
end
