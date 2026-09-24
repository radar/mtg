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

  context "with creature-dies triggers, one optional" do
    let!(:collector) do
      load_card("Parsed Collector {2}{B}\nCreature — Zombie\nWhenever another creature you control dies, you may draw a card.\n" \
                "Whenever a creature an opponent controls dies, you gain 1 life.\n2/2\n")
      ResolvePermanent("Parsed Collector", owner: p1)
    end

    it "offers a draw when another of your creatures dies, and draws if accepted" do
      ResolvePermanent("Grizzly Bears", owner: p1).destroy!
      expect(game.choices.last).to be_a(collector.card.class::CreatureDiesTrigger1::MayChoice)
      expect { game.resolve_choice! }.to change { p1.hand.count }.by(1)
    end

    it "draws nothing when declined" do
      ResolvePermanent("Grizzly Bears", owner: p1).destroy!
      expect { game.skip_choice! }.not_to(change { p1.hand.count })
    end

    it "gains life, without asking, when an opponent's creature dies" do
      ResolvePermanent("Grizzly Bears", owner: p2).destroy!
      expect(game.choices).to be_empty
      expect(p1.life).to eq(21)
    end
  end

  it "damages each opponent when you cast a noncreature spell, not a creature spell" do
    load_card("Parsed Archer {1}{R}\nCreature — Human Archer\nWhenever you cast a noncreature spell, Parsed Archer deals 1 damage to each opponent.\n3/1\n")
    ResolvePermanent("Parsed Archer", owner: p1)

    p1.add_mana(red: 1)
    p1.cast(card: Card("Lightning Bolt", owner: p1)) { _1.pay_mana(red: 1).targeting(p2) }
    expect(p2.life).to eq(19)
    game.stack.resolve!
    expect(p2.life).to eq(16)

    go_to_main_phase!
    p1.add_mana(green: 1)
    p1.cast(card: Card("Llanowar Elves", owner: p1)) { _1.pay_mana(green: 1) }
    expect(p2.life).to eq(16)
  end

  it "gains life when a generated enchantment leaves the battlefield" do
    load_card("Parsed Gift {1}{W}\nEnchantment\nWhen Parsed Gift leaves the battlefield, you gain 3 life.\n")
    ResolvePermanent("Parsed Gift", owner: p1).destroy!
    expect(p1.life).to eq(23)
  end

  it "asks, then destroys the chosen target, for an optional targeted enters trigger" do
    load_card("Parsed Shatterer {2}{R}\nCreature — Goblin\nWhen Parsed Shatterer enters, you may destroy target artifact an opponent controls.\n2/2\n")
    stone = ResolvePermanent("Mind Stone", owner: p2)
    ResolvePermanent("Mind Stone", owner: p1)
    ResolvePermanent("Parsed Shatterer", owner: p1)

    game.resolve_choice!
    expect(stone.card.zone).to be_graveyard
  end

  it "doesn't ask about an optional targeted trigger with nothing to target" do
    load_card("Parsed Wrecker {2}{R}\nCreature — Goblin\nWhen Parsed Wrecker enters, you may destroy target artifact an opponent controls.\n2/2\n")
    ResolvePermanent("Parsed Wrecker", owner: p1)
    expect(game.choices).to be_empty
  end

  it "scries, then asks for a target, for a trigger with both" do
    load_card("Parsed Seer {2}{B}\nCreature — Wizard\nWhen Parsed Seer enters, scry 1. Destroy target creature an opponent controls.\n1/1\n")
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Parsed Seer", owner: p1)

    game.resolve_choice!(top: [p1.library.first])
    game.resolve_choice!(target: bears)
    expect(bears.card.zone).to be_graveyard
  end

  it "surveils, then draws once the surveil is chosen" do
    load_card("Parsed Watcher {1}{B}\nCreature — Rogue\nWhen this creature enters, surveil 1, then draw a card.\n1/1\n")
    ResolvePermanent("Parsed Watcher", owner: p1)
    top = p1.library.first

    expect { game.resolve_choice!(graveyard: [top]) }.to change { p1.hand.count }.by(1)
    expect(top.zone).to be_graveyard
  end

  it "shrinks the opponent's creature to death on entering" do
    load_card("Parsed Blight {2}{B}\nCreature — Horror\nWhen Parsed Blight enters, target creature an opponent controls gets -2/-2 until end of turn.\n2/2\n")
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Parsed Blight", owner: p1)
    game.tick!
    expect(bears.card.zone).to be_graveyard
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
