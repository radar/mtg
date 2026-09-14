# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ImodaneThePyrohammer do
  include_context "two player game"

  let!(:imodane) { ResolvePermanent("Imodane, The Pyrohammer", owner: p1) }

  it "is a 4/4 Legendary Human Knight" do
    expect(imodane.power).to eq(4)
    expect(imodane.toughness).to eq(4)
    expect(imodane).to be_legendary
    expect(imodane.type?("Human")).to be true
    expect(imodane.type?("Knight")).to be true
  end

  it "deals that much damage to each opponent when a single-target spell you control deals damage to a creature" do
    creature = ResolvePermanent("Wood Elves", owner: p2)
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)

    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(creature) }
    game.stack.resolve!

    expect(p2.life).to eq(17)
  end

  it "does not trigger when the spell deals damage to a player instead of a creature" do
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)

    p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(17)
  end

  it "does not trigger from an opponent's spell" do
    creature = ResolvePermanent("Wood Elves", owner: p1)
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)

    p2.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(creature) }
    game.stack.resolve!

    expect(p1.life).to eq(20)
  end

  it "does not trigger from combat or fight damage dealt by a creature" do
    attacker = ResolvePermanent("Wood Elves", owner: p1)
    blocker = ResolvePermanent("Wood Elves", owner: p2)

    attacker.trigger_effect(:deal_damage, source: attacker, target: blocker, damage: 1)

    expect(p2.life).to eq(20)
  end
end
