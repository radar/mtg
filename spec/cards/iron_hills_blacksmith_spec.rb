# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IronHillsBlacksmith do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:smith) { ResolvePermanent("Iron Hills Blacksmith", owner: p1) }
  let(:axe) { p1.permanents.by_name("Axe").first }

  it "is a 1/1 Dwarf with double strike" do
    expect(smith.power).to eq(1)
    expect(smith.type?("Dwarf")).to eq(true)
    expect(smith.keywords).to include(Magic::Cards::Keywords::DOUBLE_STRIKE)
  end

  it "creates a colorless Equipment token named Axe" do
    expect(axe).not_to be_nil
    expect(axe.type?("Equipment")).to eq(true)
    expect(axe.colors).to be_empty
  end

  it "equips for {2} to give +1/+0" do
    p1.add_mana(white: 2)
    p1.activate_ability(ability: axe.activated_abilities.first) { |a| a.pay_mana(generic: { white: 2 }).targeting(smith) }
    game.stack.resolve!
    game.tick!
    expect(smith.power).to eq(2)
    expect(smith.toughness).to eq(1)
  end
end
