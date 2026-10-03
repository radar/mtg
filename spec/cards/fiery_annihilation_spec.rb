# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FieryAnnihilation do
  include_context "two player game"

  let(:spell) { Card("Fiery Annihilation", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_at(target)
    p1.hand.add(spell)
    p1.add_mana(red: 3)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { red: 2 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  def equip(creature, name = "Short Sword")
    sword = ResolvePermanent(name, owner: creature.controller)
    sword.attach_to!(creature)
    game.tick!
    sword
  end

  it "is a {2}{R} instant" do
    expect(spell.cost.cost).to eq(generic: 2, red: 1)
    expect(spell).to be_a(Magic::Cards::Instant)
  end

  it "deals 5 damage to target creature and exiles it instead of letting it die" do
    cast_at(bears)

    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
    expect(p2.graveyard.cards.map(&:name)).not_to include("Grizzly Bears")
  end

  it "leaves a creature that survives the damage alone" do
    big = ResolvePermanent("Serra Angel", owner: p2) # 4/4
    big.modify_toughness(2, until_eot: true)         # 4/6
    game.tick!
    cast_at(big)

    expect(big.zone).to be_battlefield
    expect(big.damage).to eq(5)
  end

  it "asks which attached Equipment to exile, if any" do
    sword = equip(bears)
    cast_at(bears)

    expect(game.choices.last).to be_a(Magic::Choice::ExileAttachedEquipment)
    game.resolve_choice!(target: sword)
    game.settle!

    expect(game.exile.cards.map(&:name)).to include("Short Sword", "Grizzly Bears")
  end

  it "may exile no Equipment at all" do
    sword = equip(bears)
    cast_at(bears)
    game.skip_choice!
    game.settle!

    expect(game.exile.cards.map(&:name)).not_to include("Short Sword")
    expect(sword.zone).to be_battlefield
  end

  it "queues no choice when the creature has no Equipment" do
    cast_at(bears)

    expect(game.choices).to be_empty
  end

  it "can't exile Equipment attached to a different creature" do
    other = ResolvePermanent("Grizzly Bears", owner: p2)
    sword = equip(other)
    equip(bears)
    cast_at(bears)

    expect(game.choices.last.choices).not_to include(sword)
  end
end
