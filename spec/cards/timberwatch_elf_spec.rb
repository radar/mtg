# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TimberwatchElf do
  include_context "two player game"

  let!(:elf) { ResolvePermanent("Timberwatch Elf", owner: p1) }

  it "is a 1/2 Elf" do
    expect(elf.power).to eq(1)
    expect(elf.toughness).to eq(2)
    expect(elf.type?("Elf")).to be true
  end

  it "taps to give target creature +X/+X where X is the number of Elves on the battlefield" do
    ResolvePermanent("Llanowar Elves", owner: p1)
    ResolvePermanent("Llanowar Elves", owner: p2)
    bear = ResolvePermanent("Grizzly Bears", owner: p1)

    ability = elf.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(bear.power).to eq(2 + 3)
    expect(bear.toughness).to eq(2 + 3)
  end
end
