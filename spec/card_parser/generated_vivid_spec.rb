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

  context "cost reductions" do
    before { go_to_main_phase! }

    it "costs {1} less for each color among permanents you control" do
      load_card("Parsed Giant {6}{G}\nCreature — Giant\nVivid — ~ costs {1} less to cast for each color among permanents you control.\n6/5\n")
      ResolvePermanent("Grizzly Bears", owner: p1)
      giant = Card("Parsed Giant", owner: p1)
      p1.hand.add(giant)
      p1.add_mana(green: 6)

      p1.cast(card: giant) { _1.pay_mana(generic: { green: 5 }, green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Parsed Giant")
      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "costs {1} less if you control a Kithkin" do
      load_card("Parsed Sage {4}{G}\nCreature — Kithkin\n~ costs {1} less to cast if you control a Kithkin.\n4/3\n")
      sage = Card("Parsed Sage", owner: p1)
      p1.hand.add(sage)
      p1.add_mana(green: 5)

      expect { p1.cast(card: sage) { _1.pay_mana(generic: { green: 3 }, green: 1) } }.to raise_error(StandardError)

      ResolvePermanent("Goldmeadow Nomad", owner: p1)
      p1.cast(card: sage) { _1.pay_mana(generic: { green: 3 }, green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Parsed Sage")
    end
  end

  it "pumps another creature by X at the beginning of combat" do
    load_card("Parsed Bairn {3}{U}\nCreature — Faerie\nVivid — At the beginning of combat on your turn, another target creature you control gets +X/+X until end of turn, where X is the number of colors among permanents you control.\n2/2\n")
    go_to_main_phase!
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Parsed Bairn", owner: p1)
    current_turn.beginning_of_combat!
    game.settle!

    expect([bears.power, bears.toughness]).to eq([4, 4])
  end
end
