# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AssaultOnOsgiliath do
  include_context "two player game"

  before { go_to_main_phase! }

  def armies = p1.creatures.by_type("Army")

  def counters(creature) = creature.counters.of_type(Magic::Counters::Plus1Plus1).count

  def cast(x:)
    card = Card("Assault On Osgiliath", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: x + 3)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { red: x }, red: 3) }
    game.stack.resolve!
    game.settle!
    game.tick!
    card
  end

  it "amasses Orcs X, creating an Orc Army when you have none" do
    cast(x: 3)

    expect(armies.size).to eq(1)
    expect(counters(armies.first)).to eq(3)
    expect(armies.first.type?("Orc")).to eq(true)
  end

  it "puts the counters on an existing Army" do
    existing = Magic::Amass.call(source: ResolvePermanent("Grizzly Bears", owner: p1), controller: p1, amount: 1)
    game.settle!
    cast(x: 2)

    expect(armies).to eq([existing])
    expect(counters(existing)).to eq(3)
  end

  it "gives the Army double strike and haste, so it can attack at once" do
    cast(x: 2)

    expect(armies.first).to be_double_strike
    expect(armies.first).to be_haste
  end

  it "gives your Goblins and Orcs double strike and haste, but not other creatures or opposing ones" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    opposing = ResolvePermanent("Goblin Arsonist", owner: p2)
    cast(x: 1)

    expect(goblin).to be_double_strike
    expect(goblin).to be_haste
    expect(bears).not_to be_double_strike
    expect(bears).not_to be_haste
    expect(opposing).not_to be_double_strike
    expect(opposing).not_to be_haste
  end

  it "lasts only until end of turn" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    cast(x: 1)
    expect(goblin).to be_double_strike

    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(goblin).not_to be_double_strike
    expect(goblin).not_to be_haste
  end

  it "with X = 0 the new 0/0 Army dies, but the keywords are still granted" do
    goblin = ResolvePermanent("Goblin Arsonist", owner: p1)
    cast(x: 0)

    expect(armies).to be_empty
    expect(goblin).to be_double_strike
  end

  it "is a sorcery that cannot be cast outside your main phase" do
    skip_to_combat!
    card = Card("Assault On Osgiliath", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 3)

    expect {
      p1.cast(card:, value_for_x: 0) { |a| a.pay_mana(x: { red: 0 }, red: 3) }
    }.to raise_error(Magic::IllegalAction, /main phase/)
  end
end
