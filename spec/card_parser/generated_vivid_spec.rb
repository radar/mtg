# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated Vivid effects in play" do
  include CardParserHelpers
  include_context "two player game"

  # Two colours among p1's permanents once the card itself is out (blue + a green Bears).
  def enter(name)
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent(name, owner: p1)
  end

  it "counts the colors among permanents you control" do
    expect(Magic::CardParser::Count.parse("the number of colors among permanents you control")).to eq("controller.colors_among_permanents")
    expect(Magic::CardParser::Count.parse("each color among permanents you control")).to eq("controller.colors_among_permanents")
  end

  it "draws that many cards" do
    load_card("Parsed Drawer {4}{U}\nCreature — Elemental\nVivid — When ~ enters, draw cards equal to the number of colors among permanents you control.\n3/3\n")

    expect { enter("Parsed Drawer") }.to change { p1.hand.count }.by(2)
  end

  it "gains that much life" do
    load_card("Parsed Gainer {4}{G}\nCreature — Elemental\nVivid — When ~ enters, you gain life equal to the number of colors among permanents you control.\n3/3\n")

    expect { enter("Parsed Gainer") }.to change { p1.life }.by(1)
  end

  it "drains each opponent for X and gains X, where X is the number of colors" do
    load_card("Parsed Drainer {4}{B}\nCreature — Elemental\nVivid — When ~ enters, each opponent loses X life and you gain X life, where X is the number of colors among permanents you control.\n3/3\n")
    enter("Parsed Drainer")

    expect([p1.life, p2.life]).to eq([22, 18])
  end

  it "deals X damage to a creature an opponent controls" do
    load_card("Parsed Zapper {4}{R}\nCreature — Elemental\nVivid — When ~ enters, it deals X damage to target creature an opponent controls, where X is the number of colors among permanents you control.\n3/3\n")
    victim = ResolvePermanent("Courser Of Kruphix", owner: p2)
    enter("Parsed Zapper")

    expect(victim.damage).to eq(2)
  end

  it "creates X tokens" do
    load_card("Parsed Breeder {4}{W}\nCreature — Elemental\nVivid — When ~ enters, create X 1/1 green and white Kithkin creature tokens, where X is the number of colors among permanents you control.\n3/3\n")
    enter("Parsed Breeder")

    expect(p1.creatures.count { _1.name == "Kithkin" }).to eq(2)
  end
end
