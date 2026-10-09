# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheBlackArrow do
  include_context "two player game"

  it "deals 1 damage to a player when it enters" do
    ResolvePermanent("Grizzly Bears", owner: p1) # a second target keeps the choice pending
    ResolvePermanent("The Black Arrow", owner: p1)
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(19)
  end

  it "deals 1 damage to a non-Dragon creature without destroying it" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("The Black Arrow", owner: p1)
    game.resolve_choice!(target: theirs)

    expect(theirs.damage).to eq(1)
    expect(game.battlefield.permanents).to include(theirs)
  end

  it "destroys a Dragon it damages" do
    dragon = ResolvePermanent("Ancestor Dragon", owner: p2)
    ResolvePermanent("The Black Arrow", owner: p1)
    game.resolve_choice!(target: dragon)
    game.settle!

    expect(game.battlefield.permanents).not_to include(dragon)
  end

  it "can be cast with flash" do
    arrow = Card("The Black Arrow", owner: p1)
    p1.hand.add(arrow)
    p1.add_mana(colorless: 3)
    expect { p1.cast(card: arrow) { _1.pay_mana(generic: { colorless: 3 }) } }.not_to raise_error
  end

  it "gives equipped creature +1/+1 and reach" do
    arrow = ResolvePermanent("The Black Arrow", owner: p1)
    game.resolve_choice!(target: p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(colorless: 1)
    p1.activate_ability(ability: arrow.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { colorless: 1 })
    end
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears).to have_keyword(:reach)
  end
end
