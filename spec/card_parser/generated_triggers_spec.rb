# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated triggers in play" do
  include CardParserHelpers
  include_context "two player game"

  it "draws when a generated creature dies" do
    load_card("Parsed Scholar {2}{B}\nCreature — Zombie\nWhen Parsed Scholar dies, draw a card.\n2/1\n")
    scholar = ResolvePermanent("Parsed Scholar", owner: p1)
    expect { scholar.destroy! }.to change { p1.hand.count }.by(1)
  end

  it "gains life on landfall, only for your own lands" do
    load_card("Parsed Warden {1}{G}\nCreature — Elf\nLandfall — Whenever a land you control enters, you gain 1 life.\n1/2\n")
    ResolvePermanent("Parsed Warden", owner: p1)
    ResolvePermanent("Forest", owner: p1)
    ResolvePermanent("Forest", owner: p2)
    expect(p1.life).to eq(21)
  end

  it "triggers on your instants and sorceries, not creatures or the opponent's spells" do
    load_card("Parsed Adept {1}{R}\nCreature — Wizard\nWhenever you cast an instant or sorcery spell, you gain 2 life.\n1/2\n")
    ResolvePermanent("Parsed Adept", owner: p1)

    p1.add_mana(red: 1)
    p1.cast(card: Card("Lightning Bolt", owner: p1)) { _1.pay_mana(red: 1).targeting(p2) }
    expect(p1.life).to eq(22)

    p2.add_mana(red: 1)
    p2.cast(card: Card("Lightning Bolt", owner: p2)) { _1.pay_mana(red: 1).targeting(p1) }
    expect(p1.life).to eq(22)
  end

  it "creates a token when a generated creature attacks" do
    load_card("Parsed Raider {2}{R}\nCreature — Goblin\nWhenever Parsed Raider attacks, create a 1/1 red Goblin creature token.\n2/2\n")
    raider = ResolvePermanent("Parsed Raider", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: raider, target: p2)
    current_turn.attackers_declared!

    expect(p1.creatures.map(&:name)).to include("Goblin")
  end

  it "puts a counter on a target when another creature you control enters" do
    load_card("Parsed Keeper {2}{W}\nCreature — Soldier\nAlliance — Whenever another creature enters the battlefield under your control, " \
              "put a +1/+1 counter on target creature you control.\n2/2\n")
    keeper = ResolvePermanent("Parsed Keeper", owner: p1)
    expect(game.choices).to be_empty

    ResolvePermanent("Grizzly Bears", owner: p2)
    expect(game.choices).to be_empty

    ResolvePermanent("Grizzly Bears", owner: p1)
    game.resolve_choice!(target: keeper)
    game.tick!
    expect(keeper.power).to eq(3)
  end

  context "with upkeep and end step triggers" do
    before do
      load_card("Parsed Shrine {2}{W}\nEnchantment\nAt the beginning of your upkeep, you gain 1 life.\n" \
                "At the beginning of your end step, you gain 2 life.\n")
      ResolvePermanent("Parsed Shrine", owner: p1)
    end

    it "gains life in your upkeep and end step" do
      go_to_main_phase!
      expect(p1.life).to eq(21)
      current_turn.end!
      expect(p1.life).to eq(23)
    end

    it "does nothing in the opponent's turn" do
      game.next_turn
      go_to_main_phase!
      current_turn.end!
      expect(p1.life).to eq(20)
    end
  end
end
