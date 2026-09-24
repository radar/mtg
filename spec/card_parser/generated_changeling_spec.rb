# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated changelings in play" do
  include CardParserHelpers
  include_context "two player game"

  it "lists the engine's static ability rather than defining a subclass" do
    source = generate("Parsed Shifter {1}{G}\nCreature — Shapeshifter\nChangeling\n2/2\n")
    expect(source).to include("def static_abilities = [Abilities::Static::Changeling]")
    expect(source).not_to include("class Changeling")
  end

  it "is every creature type, on the battlefield and in the hand" do
    load_card("Parsed Shifter {1}{G}\nCreature — Shapeshifter\nChangeling\n2/2\n")

    expect(Card("Parsed Shifter", owner: p1)).to be_type("Goblin")
    shifter = ResolvePermanent("Parsed Shifter", owner: p1)
    expect(shifter.types).to include(Magic::Types::Creatures["Elf"], Magic::Types::Creatures["Kithkin"])
    expect(shifter.card).to be_type("Merfolk")
  end

  it "sits alongside other static abilities" do
    load_card("Parsed Lord {1}{G}\nCreature — Shapeshifter\nChangeling\nOther creatures you control get +1/+1.\n2/2\n")
    lord = ResolvePermanent("Parsed Lord", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(lord.types).to include(Magic::Types::Creatures["Elf"])
    expect(bears.power).to eq(3)
  end
end
