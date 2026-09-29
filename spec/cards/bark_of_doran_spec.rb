# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BarkOfDoran do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bark) { ResolvePermanent("Bark Of Doran", owner: p1) }
  let!(:courser) { ResolvePermanent("Courser Of Kruphix", owner: p1) } # 2/4

  def equip!
    bark.attach_to!(courser)
    game.tick!
  end

  it "gives equipped creature +0/+1" do
    equip!

    expect([courser.power, courser.toughness]).to eq([2, 5])
  end

  it "can equip for {1}" do
    p1.add_mana(green: 1)
    p1.activate_ability(ability: bark.activated_abilities.first) { _1.pay_mana(generic: { green: 1 }).targeting(courser) }
    game.stack.resolve!
    game.tick!

    expect(courser.toughness).to eq(5)
  end

  it "assigns combat damage equal to toughness while toughness is greater than power" do
    equip!
    blocker = ResolvePermanent("Courser Of Kruphix", owner: p2)
    game.tick!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(courser, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: courser)
    current_turn.combat_damage!
    game.settle!

    expect(blocker.card.zone).to be_graveyard # 5 damage against toughness 4
  end

  it "deals damage equal to its power when its toughness isn't greater" do
    equip!
    courser.modify_power(4)
    game.tick!
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(courser, target: p2)
    current_turn.attackers_declared!
    current_turn.combat_damage!
    game.settle!

    expect(p2.life).to eq(14) # power 6, toughness 5
  end
end
