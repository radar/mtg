# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ColossalDreadmask do
  include_context "two player game"

  let!(:mask) { ResolvePermanent("Colossal Dreadmask", owner: p1) }
  let(:germ) { p1.creatures.find { _1.type?("Phyrexian") } }

  it "has living weapon: a black Germ token carries it" do
    game.tick!

    expect(germ.token?).to eq(true)
    expect(germ.colors).to eq([:black])
    expect(mask.attached_to).to eq(germ)
  end

  it "gives equipped creature +6/+6 and trample" do
    game.tick!

    expect([germ.power, germ.toughness]).to eq([6, 6])
    expect(germ).to be_trample
  end

  it "can be moved with equip {3}{G}{G}" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    go_to_main_phase!
    p1.add_mana(green: 5)
    p1.activate_ability(ability: mask.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { green: 3 }, green: 2)
    end
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([8, 8])
    expect(bears).to be_trample
    expect(p1.creatures).not_to include(germ)
  end
end
