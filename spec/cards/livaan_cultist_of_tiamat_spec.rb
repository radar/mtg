# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LivaanCultistOfTiamat do
  include_context "two player game"

  subject!(:livaan) { ResolvePermanent("Livaan, Cultist of Tiamat", owner: p1) }

  it "is a 1/3 legendary Dragon Shaman" do
    expect(livaan.power).to eq(1)
    expect(livaan.toughness).to eq(3)
    expect(livaan.types).to include("Legendary")
  end

  it "gives the only creature on the battlefield +X/+0 until end of turn when you cast a noncreature spell, where X is that spell's mana value" do
    p1.add_mana(red: 1)
    cast_action(player: p1, card: Card("Lightning Bolt", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
      .perform
    game.tick!

    expect(game.choices).to be_empty
    expect(livaan.power).to eq(2)
    expect(livaan.toughness).to eq(3)
  end

  it "lets you choose which creature gets +X/+0 when there's more than one" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)

    p1.add_mana(red: 1)
    cast_action(player: p1, card: Card("Lightning Bolt", owner: p1))
      .pay_mana(red: 1)
      .targeting(p2)
      .perform
    game.tick!

    expect(game.choices).not_to be_empty
    game.resolve_choice!(target: bear)
    game.tick!

    expect(bear.power).to eq(3)
    expect(bear.toughness).to eq(2)
    expect(livaan.power).to eq(1)
  end

  it "doesn't trigger when you cast a creature spell" do
    p1.add_mana(green: 2)
    cast_action(player: p1, card: Card("Grizzly Bears", owner: p1))
      .pay_mana(generic: { green: 1 }, green: 1)
      .perform
    game.tick!

    expect(game.choices).to be_empty
    expect(livaan.power).to eq(1)
  end
end
