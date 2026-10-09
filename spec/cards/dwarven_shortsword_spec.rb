# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DwarvenShortsword do
  include_context "two player game"

  let!(:sword) { ResolvePermanent("Dwarven Shortsword", owner: p1) }
  let(:dwarf) { p1.creatures.find { _1.type?("Dwarf") } }

  it "creates a 2/2 red Dwarf token and attaches itself to it" do
    game.tick!
    expect(dwarf).not_to be_nil
    expect(dwarf.token?).to eq(true)
    expect(sword.attached_to).to eq(dwarf)
    expect(dwarf.colors).to eq([:red])
  end

  it "gives equipped creature +1/+2" do
    game.tick!
    expect([dwarf.power, dwarf.toughness]).to eq([3, 4])
  end

  it "can be moved with equip {2}" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    go_to_main_phase!
    p1.add_mana(white: 2)
    p1.activate_ability(ability: sword.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { white: 2 })
    end
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 4])
    expect([dwarf.power, dwarf.toughness]).to eq([2, 2])
  end
end
