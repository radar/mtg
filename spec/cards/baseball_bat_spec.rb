# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BaseballBat do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:bat) { ResolvePermanent("Baseball Bat", owner: p1) }

  before { game.tick! }

  it "attaches to a creature you control when it enters" do
    expect(bat.attached_to).to eq(bears)
  end

  it "gives equipped creature +1/+1" do
    expect([bears.power, bears.toughness]).to eq([3, 3])
  end

  it "has equip {3}" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    go_to_main_phase!
    p1.add_mana(green: 3)
    p1.activate_ability(ability: bat.activated_abilities.first) do
      _1.targeting(other)
      _1.pay_mana(generic: { green: 3 })
    end
    game.stack.resolve!
    game.tick!
    expect(bat.attached_to).to eq(other)
    expect([other.power, other.toughness]).to eq([3, 3])
  end

  it "taps a target creature when the equipped creature attacks" do
    go_to_main_phase!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    game.settle!

    choice = game.choices.last
    expect(choice).to be_a(described_class::AttacksTrigger::TapChoice)
    game.resolve_choice!(target: blocker)

    expect(blocker).to be_tapped
  end
end
