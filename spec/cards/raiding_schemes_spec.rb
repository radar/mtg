# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RaidingSchemes do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:schemes) { ResolvePermanent("Raiding Schemes", owner: p1) }

  def bolt = Card("Lightning Bolt", owner: p1)

  def cast_bolt(target, &block)
    card = bolt
    p1.hand.add(card)
    p1.add_mana(red: 1)
    p1.cast(card:) do |action|
      block&.call(action)
      action.pay_mana(red: 1).targeting(target)
    end
    game.settle!
    card
  end

  it "conspire: tap two untapped creatures that share a color with the spell to copy it" do
    reds = [ResolvePermanent("Sizzling Changeling", owner: p1), ResolvePermanent("Sizzling Changeling", owner: p1)]
    cast_bolt(p2) { _1.conspire(*reds) }
    game.skip_choice! # keep the target for the copy
    game.stack.resolve!

    expect(reds).to all(be_tapped)
    expect(p2.life).to eq(14) # the bolt and its copy
  end

  it "lets the copy choose a new target" do
    reds = [ResolvePermanent("Sizzling Changeling", owner: p1), ResolvePermanent("Sizzling Changeling", owner: p1)]
    victim = ResolvePermanent("Courser Of Kruphix", owner: p2)
    cast_bolt(p2) { _1.conspire(*reds) }
    game.resolve_choice! # choose new targets
    game.resolve_choice!(target: victim)
    game.stack.resolve!

    expect(p2.life).to eq(17)
    expect(victim.damage).to eq(3)
  end

  it "is optional: casting without conspiring makes no copy" do
    cast_bolt(p2)
    game.stack.resolve!

    expect(p2.life).to eq(17)
  end

  it "requires the creatures to share a color with the spell" do
    greens = [ResolvePermanent("Grizzly Bears", owner: p1), ResolvePermanent("Grizzly Bears", owner: p1)]
    card = bolt
    p1.hand.add(card)
    p1.add_mana(red: 1)

    expect { p1.cast(card:) { _1.conspire(*greens) } }.to raise_error(/share a color/)
  end

  it "requires two different untapped creatures you control" do
    red = ResolvePermanent("Sizzling Changeling", owner: p1)
    red.tap!
    other = ResolvePermanent("Sizzling Changeling", owner: p1)
    card = bolt
    p1.hand.add(card)

    expect { p1.cast(card:) { _1.conspire(red, other) } }.to raise_error(/is tapped/)
    expect { p1.cast(card:) { _1.conspire(other, other) } }.to raise_error(/two different/)
  end

  it "only grants conspire to noncreature spells" do
    reds = [ResolvePermanent("Sizzling Changeling", owner: p1), ResolvePermanent("Sizzling Changeling", owner: p1)]
    card = Card("Sizzling Changeling", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 3)

    expect { p1.cast(card:) { _1.conspire(*reds) } }.to raise_error(/does not have conspire/)
  end

  it "does not grant it to the opponent" do
    go_to_main_phase_for!(p2)
    reds = [ResolvePermanent("Sizzling Changeling", owner: p2), ResolvePermanent("Sizzling Changeling", owner: p2)]
    card = Card("Lightning Bolt", owner: p2)
    p2.hand.add(card)

    expect { p2.cast(card:) { _1.conspire(*reds) } }.to raise_error(/does not have conspire/)
  end

  it "a copy of a noncreature permanent spell becomes a token" do
enchantment = Card("Clachan Festival", owner: p1) # a white Kindred enchantment
whites = [ResolvePermanent("Alaborn Trooper", owner: p1), ResolvePermanent("Alaborn Trooper", owner: p1)]
p1.hand.add(enchantment)
p1.add_mana(white: 3)
p1.cast(card: enchantment) { |action| action.conspire(*whites).pay_mana(generic: { white: 2 }, white: 1) }
game.stack.resolve!
game.settle!

    festivals = p1.permanents.select { _1.name == "Clachan Festival" }
    expect(festivals.size).to eq(2)
    expect(festivals.count(&:token?)).to eq(1)
  end
end
