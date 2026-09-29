# frozen_string_literal: true

require "spec_helper"
require_relative "../card_parser_helpers"

RSpec.describe Magic::CardParser::Rules::CharacteristicPower do
  include CardParserHelpers
  include_context "two player game"

  it "parses \"~'s power is equal to <count>\"" do
    rule = described_class.parse("~'s power is equal to the number of colors among permanents you control.")

    expect(rule.class_source("CharacteristicPower")).to include("def power_modification = controller.colors_among_permanents")
    expect(described_class.parse("~'s power is equal to the moon")).to be_nil
  end

  it "refuses a * power with no rule to define it" do
    expect { Magic::CardParser.parse("Parsed Blank {1}\nCreature — Elemental\n*/4\n") }.to raise_error(Magic::CardParser::UnsupportedCard)
  end

  it "has power equal to the colors among your permanents, in play" do
    load_card("Parsed Roaster {3}{R}\nCreature — Elemental\nDouble strike\nVivid — ~'s power is equal to the number of colors among permanents you control.\n*/4\n")
    roaster = ResolvePermanent("Parsed Roaster", owner: p1)
    game.tick!
    expect([roaster.power, roaster.toughness]).to eq([1, 4])

    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    expect(roaster.power).to eq(2)
  end
end
