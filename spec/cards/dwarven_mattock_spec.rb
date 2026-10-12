# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DwarvenMattock do
  include_context "two player game"

  let!(:dwarf) { ResolvePermanent("Dwarven Provisioner", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:mattock) { ResolvePermanent("Dwarven Mattock", owner: p1) }

  it "attaches itself to a Dwarf you control when it enters (the lone Dwarf is chosen automatically)" do
    game.tick!
    expect(mattock.attached_to).to eq(dwarf)
  end

  it "gives equipped creature +2/+2" do
    game.tick!
    expect([dwarf.power, dwarf.toughness]).to eq([4, 4])
    expect([bears.power, bears.toughness]).to eq([2, 2])
  end

  it "has equip {3}" do
    go_to_main_phase!
    p1.add_mana(green: 3)
    p1.activate_ability(ability: mattock.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { green: 3 })
    end
    game.stack.resolve!
    game.tick!
    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "gives equipped creature ward {1}" do
    game.tick!
    go_to_main_phase_for!(p2)
    p2.add_mana(red: 1)
    p2.cast(card: Card("Burst Lightning", owner: p2)) { |a| a.pay_mana(red: 1).targeting(dwarf) }
    game.settle!

    ward = game.choices.last
    expect(ward).to be_a(Magic::Choice::Ward)
    expect(ward.generic).to eq(1)
  end

  it "doesn't ward the unequipped creature" do
    game.tick!
    go_to_main_phase_for!(p2)
    p2.add_mana(red: 1)
    p2.cast(card: Card("Burst Lightning", owner: p2)) { |a| a.pay_mana(red: 1).targeting(bears) }
    game.settle!

    expect(game.choices.last).to be_nil
  end
end
