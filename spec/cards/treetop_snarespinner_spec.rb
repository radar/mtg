# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TreetopSnarespinner do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:spinner) { ResolvePermanent("Treetop Snarespinner", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 1/4 Spider with reach and deathtouch" do
    expect([spinner.power, spinner.toughness]).to eq([1, 4])
    expect(spinner).to be_reach
    expect(spinner).to be_deathtouch
  end

  it "puts a +1/+1 counter on target creature you control for {2}{G}" do
    p1.add_mana(green: 3)
    p1.activate_ability(ability: spinner.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }, green: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 3])
  end

  it "can only be activated as a sorcery" do
    go_to_main_phase_for!(p2)
    p1.add_mana(green: 3)

    expect { p1.activate_ability(ability: spinner.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }, green: 1).targeting(bears) } }
      .to raise_error(Magic::IllegalAction)
  end
end
