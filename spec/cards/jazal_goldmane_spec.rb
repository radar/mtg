# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JazalGoldmane do
  include_context "two player game"

  let!(:jazal) { ResolvePermanent("Jazal Goldmane", owner: p1) }

  it "is a 4/4 with first strike" do
    expect([jazal.power, jazal.toughness]).to eq([4, 4])
    expect(jazal).to have_keyword(:first_strike)
  end

  it "gives each attacking creature you control +X/+X, X being the number of attacking creatures" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: jazal, target: p2)
    p1.declare_attacker(attacker: bears, target: p2)
    current_turn.attackers_declared!

    p1.add_mana(white: 5)
    p1.activate_ability(ability: jazal.activated_abilities.first) { |a| a.pay_mana(generic: { white: 3 }, white: 2) }
    game.stack.resolve!
    game.tick!

    expect([jazal.power, jazal.toughness]).to eq([6, 6])
    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "does not pump a creature that isn't attacking" do
    idle = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: jazal, target: p2)
    current_turn.attackers_declared!

    p1.add_mana(white: 5)
    p1.activate_ability(ability: jazal.activated_abilities.first) { |a| a.pay_mana(generic: { white: 3 }, white: 2) }
    game.stack.resolve!
    game.tick!

    expect(jazal.power).to eq(5)
    expect(idle.power).to eq(2)
  end
end
