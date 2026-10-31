# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElvenChorus do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:chorus) { ResolvePermanent("Elven Chorus", owner: p1) }

  it "is a 4-mana enchantment" do
    expect(chorus.type?("Enchantment")).to be(true)
    expect(chorus.card.cost.to_s).to include("3")
  end

  it "lets only its controller look at the top card" do
    ability = chorus.static_abilities.first

    expect(ability.may_look_at_top_card?(p1)).to be(true)
    expect(ability.may_look_at_top_card?(p2)).to be(false)
  end

  it "allows casting a creature from the top of the library and resolving it" do
    creature = Card("Grizzly Bears", owner: p1)
    p1.library.add(creature, 0)
    p1.add_mana(green: 2)
    p1.cast(card: creature) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
    game.settle!

    expect(p1.creatures.map(&:card)).to include(creature)
    expect(p1.library.cards).not_to include(creature)
  end

  it "does not allow casting a noncreature, a buried creature, or the opponent's top creature" do
    spell = Card("Lightning Bolt", owner: p1)
    p1.library.add(spell, 0)
    p1.add_mana(red: 1)
    expect(p1.prepare_cast(card: spell).can_perform?).to be(false)

    creature = Card("Grizzly Bears", owner: p1)
    p1.library.add(creature, 0)
    p1.library.add(Card("Forest", owner: p1), 0)
    p1.add_mana(generic: 1, green: 1)
    expect(p1.prepare_cast(card: creature).can_perform?).to be(false)

    theirs = Card("Grizzly Bears", owner: p2)
    p2.library.add(theirs, 0)
    p2.add_mana(generic: 1, green: 1)
    expect(p2.prepare_cast(card: theirs).can_perform?).to be(false)
  end

  it "lets creatures you control tap for one mana of any color" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    p1.activate_ability(ability: bear.activated_abilities.first) { |a| a.choose(:blue) }

    expect(p1.mana_pool[:blue]).to eq(1)
    expect(bear).to be_tapped
  end

  it "does not grant the ability to opponent's creatures" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(bear.activated_abilities).to be_empty
  end
end
