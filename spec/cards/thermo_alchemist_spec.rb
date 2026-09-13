# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThermoAlchemist do
  include_context "two player game"

  subject!(:alchemist) { ResolvePermanent("Thermo-Alchemist", owner: p1) }

  it "is a 0/3 Human Shaman with defender" do
    expect(alchemist.power).to eq(0)
    expect(alchemist.toughness).to eq(3)
    expect(alchemist.defender?).to eq(true)
  end

  it "deals 1 damage to each opponent when tapped" do
    ability = alchemist.activated_abilities.first
    p1.activate_ability(ability: ability)
    game.stack.resolve!

    expect(p2.life).to eq(19)
    expect(alchemist.tapped?).to eq(true)
  end

  it "untaps when you cast an instant or sorcery spell" do
    alchemist.tap!

    p1.add_mana(red: 1)
    cast_action(player: p1, card: Card("Lightning Bolt", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
      .perform
    game.tick!

    expect(alchemist.tapped?).to eq(false)
  end

  it "doesn't untap when you cast a creature spell" do
    alchemist.tap!

    p1.add_mana(green: 2)
    cast_action(player: p1, card: Card("Grizzly Bears", owner: p1))
      .pay_mana(generic: { green: 1 }, green: 1)
      .perform
    game.tick!

    expect(alchemist.tapped?).to eq(true)
  end
end
