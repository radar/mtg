# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DawnwingMarshal do
  include_context "two player game"

  let!(:marshal) { ResolvePermanent("Dawnwing Marshal", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 2/2 flyer" do
    expect([marshal.power, marshal.toughness]).to eq([2, 2])
    expect(marshal).to be_flying
  end

  it "gives creatures you control +1/+1 until end of turn for {4}{W}" do
    p1.add_mana(white: 5)
    p1.activate_ability(ability: marshal.activated_abilities.first) { _1.pay_mana(generic: { white: 4 }, white: 1) }
    game.stack.resolve!
    game.tick!

    expect([marshal.power, marshal.toughness]).to eq([3, 3])
    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect([rival.power, rival.toughness]).to eq([2, 2])
  end
end
