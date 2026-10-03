# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HeartfireImmolator do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:immolator) { ResolvePermanent("Heartfire Immolator", owner: p1) }

  def sacrifice(target)
    p1.add_mana(red: 1)
    p1.activate_ability(ability: immolator.activated_abilities.first) { |a| a.pay_mana(red: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "is a 2/2 Human Wizard with prowess" do
    expect([immolator.power, immolator.toughness]).to eq([2, 2])
    expect(immolator.card.keywords).to include(Magic::Cards::Keywords::PROWESS)
  end

  it "gets +1/+1 from a noncreature spell (prowess)" do
    spell = Card("Shock", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(red: 1)
    p1.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!

    expect(immolator.power).to eq(3)
  end

  it "deals damage equal to its power to target creature when sacrificed" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    sacrifice(bears)

    expect(immolator.card.zone).to be_graveyard
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "uses its boosted power" do
    big = ResolvePermanent("Serra Angel", owner: p2) # 4/4
    shock = Card("Shock", owner: p1)
    p1.hand.add(shock)
    p1.add_mana(red: 1)
    p1.cast(card: shock) { |a| a.pay_mana(red: 1).targeting(p2) }
    game.settle!
    expect(immolator.power).to eq(3)
    sacrifice(big)

    expect(big.damage).to eq(3)
  end

  it "can target a planeswalker" do
    walker = ResolvePermanent("Teferi Master Of Time", owner: p2)
    loyalty = walker.loyalty
    sacrifice(walker)

    expect(walker.loyalty).to eq(loyalty - 2)
  end

  it "can't target a player" do
    p1.add_mana(red: 1)

    expect { p1.activate_ability(ability: immolator.activated_abilities.first) { |a| a.pay_mana(red: 1).targeting(p2) } }
      .to raise_error(RuntimeError)
  end
end
