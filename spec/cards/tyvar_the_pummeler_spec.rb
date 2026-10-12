# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TyvarThePummeler do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:tyvar) { ResolvePermanent("Tyvar, The Pummeler", owner: p1) }
  let!(:helper) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a legendary 3/3 Elf Warrior" do
    expect([tyvar.power, tyvar.toughness]).to eq([3, 3])
    expect(tyvar.card.types).to include("Elf", "Warrior")
    expect(tyvar.card).to be_legendary
  end

  it "gains indestructible until end of turn by tapping another untapped creature" do
    p1.activate_ability(ability: tyvar.activated_abilities.first) do |action|
      action.pay_multi_tap([helper])
    end
    game.stack.resolve!
    game.tick!

    expect(helper).to be_tapped
    expect(tyvar).to have_keyword(:indestructible)
    expect(tyvar).not_to be_tapped
  end

  it "can't tap itself for the indestructible cost" do
    expect do
      p1.activate_ability(ability: tyvar.activated_abilities.first) { |action| action.pay_multi_tap([tyvar]) }
    end.to raise_error(/Tap exactly 1/)
  end

  it "gives creatures you control +X/+X where X is the greatest power among them" do
    opp = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(green: 5)
    p1.activate_ability(ability: tyvar.activated_abilities.last) do |action|
      action.pay_mana(generic: { green: 3 }, green: 2)
    end
    game.stack.resolve!
    game.tick!

    expect([tyvar.power, tyvar.toughness]).to eq([6, 6])
    expect([helper.power, helper.toughness]).to eq([5, 5])
    expect([opp.power, opp.toughness]).to eq([2, 2])
  end
end
