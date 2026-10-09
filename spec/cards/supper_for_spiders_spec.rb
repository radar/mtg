# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SupperForSpiders do
  include_context "two player game"

  let(:supper) { Card("Supper For Spiders", owner: p1) }

  before { p1.hand.add(supper) }

  # Cast (rather than ResolvePermanent) so the card really comes from the battlefield when it dies.
  def creature_for(player, name)
    card = Card(name, owner: player)
    cast_and_resolve(card: card, player: player)
    player.creatures.find { _1.card == card }
  end

  def cast_supper
    p1.add_mana(black: 2)
    p1.cast(card: supper) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  def foods = p1.permanents.select { _1.type?("Food") }

  it "puts creatures that died from the battlefield this turn under your control as Food artifacts" do
    victim = creature_for(p2, "Grizzly Bears")
    victim.destroy!
    game.settle!
    cast_supper

    expect(foods.map(&:name)).to eq(["Grizzly Bears"])
    food = foods.first
    expect(food).to be_artifact
    expect(food).not_to be_creature
    expect(food.type?("Bear")).to be(false)
    expect(food.controller).to eq(p1)
    expect(p2.graveyard.cards).to be_empty
  end

  it "ignores creature cards that were put into the graveyard some other way" do
    milled = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(milled)
    cast_supper

    expect(foods).to be_empty
    expect(p2.graveyard.cards).to include(milled)
  end

  it "ignores creatures that died on an earlier turn" do
    victim = creature_for(p2, "Grizzly Bears")
    victim.destroy!
    game.settle!
    game.next_turn
    go_to_main_phase_for!(p1)
    cast_supper

    expect(foods).to be_empty
  end

  it "ignores your own creatures" do
    mine = creature_for(p1, "Grizzly Bears")
    mine.destroy!
    game.settle!
    cast_supper

    expect(foods).to be_empty
  end

  it "gives each one '{2}, {T}, Sacrifice this artifact: You gain 3 life'" do
    victim = creature_for(p2, "Ordinary Bear")
    victim.destroy!
    game.settle!
    cast_supper
    food = foods.first
    food.untap!
    p1.add_mana(colorless: 2)
    ability = food.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.pay_mana(generic: { colorless: 2 }) }
    game.stack.resolve!
    game.settle!

    expect(p1.life).to eq(23)
    expect(p1.permanents).not_to include(food)
  end
end
