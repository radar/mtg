# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AllosaurusShepherd do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:shepherd) { ResolvePermanent("Allosaurus Shepherd", owner: p1) }

  it "is a 1/1 Elf Shaman" do
    expect(shepherd.power).to eq(1)
    expect(shepherd.toughness).to eq(1)
    expect(shepherd.type?("Elf")).to be true
  end

  it "can't itself be countered" do
    spell = Card("Allosaurus Shepherd", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 1)
    action = p1.cast(card: spell) { |a| a.pay_mana(green: 1) }

    game.add_effect(Magic::Effects::CounterSpell.new(source: shepherd, target: action))

    expect(game.stack.include?(action)).to be true
  end

  it "prevents green spells you control from being countered" do
    bear_spell = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bear_spell)
    p1.add_mana(green: 2)
    action = p1.cast(card: bear_spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

    game.add_effect(Magic::Effects::CounterSpell.new(source: shepherd, target: action))

    expect(game.stack.include?(action)).to be true
  end

  it "does not prevent countering a non-green spell you control" do
    black_spell = Card("Doom Blade", owner: p1)
    p1.hand.add(black_spell)
    p1.add_mana(black: 2)
    action = p1.cast(card: black_spell) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }

    game.add_effect(Magic::Effects::CounterSpell.new(source: shepherd, target: action))

    expect(game.stack.include?(action)).to be false
  end

  it "does not prevent countering an opponent's green spells" do
    go_to_main_phase_for!(p2)
    opponents_spell = Card("Llanowar Elves", owner: p2)
    p2.hand.add(opponents_spell)
    p2.add_mana(green: 1)
    action = p2.cast(card: opponents_spell) { |a| a.pay_mana(green: 1) }

    game.add_effect(Magic::Effects::CounterSpell.new(source: shepherd, target: action))

    expect(game.stack.include?(action)).to be false
  end

  it "gives Elves you control base power and toughness 5/5 and Dinosaur type until end of turn for {4}{G}{G}" do
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 6)

    ability = shepherd.activated_abilities.first
    p1.activate_ability(ability: ability) { |a| a.pay_mana(generic: { green: 4 }, green: 2) }
    game.stack.resolve!
    game.tick!

    expect(elf.power).to eq(5)
    expect(elf.toughness).to eq(5)
    expect(elf.type?("Dinosaur")).to be true
    expect(elf.type?("Elf")).to be true
    expect(bear.power).to eq(2)
  end
end
