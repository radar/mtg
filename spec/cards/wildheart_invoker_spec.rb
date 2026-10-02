# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WildheartInvoker do
  include_context "two player game"

  let!(:invoker) { ResolvePermanent("Wildheart Invoker", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 4/3 Elf Shaman" do
    expect([invoker.power, invoker.toughness]).to eq([4, 3])
  end

  it "gives target creature +5/+5 and trample until end of turn for {8}" do
    p1.add_mana(green: 8)
    p1.activate_ability(ability: invoker.activated_abilities.first) { _1.pay_mana(generic: { green: 8 }).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([7, 7])
    expect(bears).to be_trample
  end
end
