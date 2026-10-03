# frozen_string_literal: true

require "spec_helper"
require_relative "../card_parser_helpers"

RSpec.describe "CardParser token shapes (counts, tapped, named, legendary, copies)" do
  include CardParserHelpers
  include_context "two player game"

  def tokens(name) = p1.permanents.by_name(name).to_a

  def cast_sorcery(name)
    go_to_main_phase!
    card = Card(name, owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 10)
    p1.cast(card:) { |a| a.pay_mana(generic: { white: 1 }) }
    game.stack.resolve!
    game.settle!
  end

  it "creates tapped tokens for each creature card in your graveyard" do
    load_card("Parsed Rats {1}\nSorcery\nCreate a tapped 1/1 black Rat creature token for each creature card in your graveyard.\n")
    2.times { p1.graveyard.add(Card("Aegis Turtle", owner: p1)) }
    cast_sorcery("Parsed Rats")

    expect(tokens("Rat").size).to eq(2)
    expect(tokens("Rat")).to all(be_tapped)
    expect(tokens("Rat").map(&:colors).uniq).to eq([[:black]])
  end

  it "creates no tokens when the count is zero" do
    load_card("Parsed Rats {1}\nSorcery\nCreate a tapped 1/1 black Rat creature token for each creature card in your graveyard.\n")
    cast_sorcery("Parsed Rats")

    expect(tokens("Rat")).to be_empty
  end

  it "creates named tokens" do
    result = Magic::CardParser.parse("Parsed Serpent {1}\nSorcery\nCreate four 3/3 blue Serpent creature tokens named Parsed's Coil.\n")
    expect(result).to be_a(Magic::CardParser::Result)
    load_card("Parsed Serpent {1}\nSorcery\nCreate four 3/3 blue Serpent creature tokens named Parsed's Coil.\n")
    cast_sorcery("Parsed Serpent")

    expect(tokens("Parsed's Coil").size).to eq(4)
    expect(tokens("Parsed's Coil").first.power).to eq(3)
  end

  it "creates a legendary named token" do
    load_card("Parsed Octopus {1}\nSorcery\nCreate Scion of Parse, a legendary 8/8 blue Octopus creature token.\n")
    cast_sorcery("Parsed Octopus")

    scion = tokens("Scion of Parse").first
    expect(scion.power).to eq(8)
    expect(scion.type?("Legendary")).to eq(true)
    expect(scion.type?("Octopus")).to eq(true)
  end

  it "counts other creatures you control named ~ for a number of tokens" do
    load_card("Parsed Hare {1}{W}\nCreature — Rabbit\nWhen ~ enters, create a number of 1/1 white Rabbit creature tokens equal to the number of other creatures you control named ~.\nA deck can have any number of cards named ~.\n2/2\n")
    go_to_main_phase!
    2.times { ResolvePermanent("Parsed Hare", owner: p1) }
    expect(tokens("Rabbit").size).to eq(1)

    ResolvePermanent("Parsed Hare", owner: p2)
    expect(tokens("Rabbit").size).to eq(1)
    expect(p2.permanents.by_name("Rabbit")).to be_empty
  end

  it "creates a token copy of ~" do
    load_card("Parsed Horde {2}{U}\nCreature — Homunculus\nWhenever you draw your second card each turn, create a token that's a copy of ~.\n2/2\n")
    ResolvePermanent("Parsed Horde", owner: p1)
    2.times { p1.draw! }
    game.settle!

    copies = tokens("Parsed Horde")
    expect(copies.size).to eq(2)
    expect(copies.count(&:token?)).to eq(1)
  end

  it "copies a target creature with haste and an end step sacrifice" do
    load_card("Parsed Duplicate {1}{R}\nSorcery\nCreate a token that's a copy of target creature you control, except it has haste and \"At the beginning of the end step, sacrifice this token.\"\n")
    ResolvePermanent("Aegis Turtle", owner: p1)
    go_to_main_phase!
    card = Card("Parsed Duplicate", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 1 }, red: 1).targeting(p1.creatures.first) }
    game.stack.resolve!
    game.settle!

    copy = tokens("Aegis Turtle").find(&:token?)
    expect(copy.haste?).to eq(true)

    current_turn.end!
    game.settle!
    expect(tokens("Aegis Turtle").size).to eq(1)
  end

  it "reads a leading 'Until end of turn,' on a pump" do
    load_card("Parsed Rally {1}\nSorcery\nCreate two 1/1 white Soldier creature tokens. Until end of turn, creatures you control get +1/+1 and gain haste.\n")
    cast_sorcery("Parsed Rally")

    soldiers = tokens("Soldier")
    expect(soldiers.size).to eq(2)
    expect(soldiers.map(&:power)).to eq([2, 2])
    expect(soldiers.map(&:toughness)).to eq([2, 2])
    expect(soldiers).to all(satisfy(&:haste?))
  end
end
