# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DwarvenProvisioner do
  include_context "two player game"

  let!(:provisioner) { ResolvePermanent("Dwarven Provisioner", owner: p1) }

  it "is a 2/2 Dwarf Citizen" do
    expect(provisioner.power).to eq(2)
    expect(provisioner.toughness).to eq(2)
    expect(provisioner.type?("Dwarf")).to eq(true)
  end

  it "pumps creatures you control, but not the opponent's, for {3}{W}" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    opp_bears = ResolvePermanent("Grizzly Bears", owner: p2)

    p1.add_mana(white: 4)
    p1.activate_ability(ability: provisioner.activated_abilities.first) do
      _1.pay_mana(generic: { white: 3 }, white: 1)
    end
    game.stack.resolve!
    game.tick!

    expect([provisioner.power, provisioner.toughness]).to eq([3, 3])
    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect([opp_bears.power, opp_bears.toughness]).to eq([2, 2])
  end
end
