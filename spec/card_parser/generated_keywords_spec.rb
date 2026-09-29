# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated keywords with values, in play" do
  include CardParserHelpers
  include_context "two player game"

  context "toxic, flying, ward and protection" do
    let!(:sentry) do
      load_card("Parsed Sentry {2}{W}\nCreature — Phyrexian Cleric\nToxic 1\nFlying, ward {2}\n" \
                "Protection from red\n1/4\n")
      ResolvePermanent("Parsed Sentry", owner: p1)
    end

    it "gives a poison counter when it deals combat damage to a player" do
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(sentry, target: p2)
      current_turn.attackers_declared!
      go_to_combat_damage!

      expect(p2.counters.of_type(Magic::Counters::Poison).count).to eq(1)
    end

    it "can't be blocked by a red creature" do
      ogre = ResolvePermanent("Onakke Ogre", owner: p2)
      ogre.grant_keyword(Magic::Keywords::REACH)
      game.tick!
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(sentry, target: p2)
      current_turn.attackers_declared!

      expect(current_turn.can_block?(attacker: sentry, blocker: ogre)).to eq(false)
    end

    it "asks an opponent targeting it to pay for ward" do
      p2.add_mana(black: 2)
      p2.cast(card: Card("Doom Blade", owner: p2)) { _1.pay_mana(generic: { black: 1 }, black: 1).targeting(sentry) }
      game.settle!

      expect(game.choices.last).to be_a(Magic::Choice::Ward)
    end
  end

  it "makes an opponent targeting it pay life or be countered for ward—pay life" do
    load_card("Parsed Weaver {2}{G}\nCreature — Spider\nReach, hexproof from blue\nWard—Pay 3 life.\n2/3\n")
    weaver = ResolvePermanent("Parsed Weaver", owner: p1)
    expect(weaver.hexproof_from?(:blue)).to eq(true)

    p2.add_mana(red: 1)
    p2.cast(card: Card("Shock", owner: p2)) { _1.pay_mana(red: 1).targeting(weaver) }
    game.settle!

    expect(game.choices.last).to be_a(Magic::Choice::Ward)
    game.resolve_choice!(pay_life: true)
    game.settle!

    expect(p2.life).to eq(17)
  end

  context "kicker" do
    before do
      load_card("Parsed Badger {2}{G}\nCreature — Badger\nKicker {1}{B}\n" \
                "When Parsed Badger enters, if it was kicked, draw a card.\n3/3\n")
      go_to_main_phase!
    end

    let(:badger) { Card("Parsed Badger", owner: p1).tap { p1.hand.add(_1) } }

    it "draws a card when kicked" do
      p1.add_mana(green: 3, black: 2)
      action = cast_action(card: badger, player: p1)
      action.pay_mana(green: 1, generic: { green: 2 })
      action.pay_kicker(generic: { black: 1 }, black: 1)

      expect { game.take_action(action); game.stack.resolve! }.to change { p1.hand.count }.by(0)
    end

    it "doesn't draw when not kicked" do
      p1.add_mana(green: 3)
      action = cast_action(card: badger, player: p1)
      action.pay_mana(green: 1, generic: { green: 2 })

      expect { game.take_action(action); game.stack.resolve! }.to change { p1.hand.count }.by(-1)
    end
  end

  context "if this spell was kicked" do
    before do
      load_card("Parsed Blast {1}{R}\nInstant\nKicker {2}\n" \
                "Parsed Blast deals 2 damage to any target. If this spell was kicked, draw a card and you gain 2 life.\n")
    end

    let(:blast) { Card("Parsed Blast", owner: p1).tap { p1.hand.add(_1) } }

    it "runs the extra effects when kicked" do
      p1.add_mana(red: 4)
      p1.cast(card: blast) do |action|
        action.pay_mana(generic: { red: 1 }, red: 1).targeting(p2)
        action.pay_kicker(generic: { red: 2 })
      end

      top_card = p1.library.first
      game.stack.resolve!

      expect(p1.hand).to include(top_card)
      expect(p2.life).to eq(18)
      expect(p1.life).to eq(22)
    end

    it "skips them when not kicked" do
      p1.add_mana(red: 2)
      p1.cast(card: blast) { _1.pay_mana(generic: { red: 1 }, red: 1).targeting(p2) }

      top_card = p1.library.first
      game.stack.resolve!

      expect(p1.hand).not_to include(top_card)
      expect(p2.life).to eq(18)
      expect(p1.life).to eq(20)
    end

    it "works inside a mode" do
      load_card("Parsed Charm {1}{B}\nInstant\nKicker {1}\nChoose one —\n" \
                "• Draw a card. If this spell was kicked, you gain 3 life.\n• Each opponent loses 2 life.\n")
      charm = Card("Parsed Charm", owner: p1)
      p1.hand.add(charm)
      p1.add_mana(black: 3)
      p1.cast(card: charm) do |action|
        action.choose_mode(charm.modes[0])
        action.pay_mana(generic: { black: 1 }, black: 1)
        action.pay_kicker(generic: { black: 1 })
      end
      game.stack.resolve!

      expect(p1.life).to eq(23)
    end

    it "isn't supported on a triggered ability" do
      expect { generate("Parsed Bird {1}{U}\nCreature — Bird\nWhen Parsed Bird enters, draw a card. " \
                        "If this spell was kicked, you gain 2 life.\n1/1\n") }
        .to raise_error(Magic::CardParser::UnsupportedCard, /only works on instants and sorceries/)
    end
  end

  context "if this spell was kicked, ... instead" do
    def cast_kicked(card, kicked:, &block)
      p1.hand.add(card)
      p1.add_mana(red: 5, green: 5)
      p1.cast(card:) do |action|
        block.(action)
        action.pay_mana(generic: { red: 1 }, red: 1)
        action.pay_kicker(generic: { red: 2 }) if kicked
      end
      game.stack.resolve!
    end

    it "deals the replacement damage to the same target" do
      load_card("Parsed Bolt {1}{R}\nInstant\nKicker {2}\n" \
                "Parsed Bolt deals 2 damage to any target. If this spell was kicked, it deals 4 damage instead.\n")

      cast_kicked(Card("Parsed Bolt", owner: p1), kicked: true) { _1.targeting(p2) }
      expect(p2.life).to eq(16)
    end

    it "deals the base damage when not kicked" do
      load_card("Parsed Bolt {1}{R}\nInstant\nKicker {2}\n" \
                "Parsed Bolt deals 2 damage to any target. If this spell was kicked, it deals 4 damage instead.\n")

      cast_kicked(Card("Parsed Bolt", owner: p1), kicked: false) { _1.targeting(p2) }
      expect(p2.life).to eq(18)
    end

    it "reads the leading form and a pronoun target" do
      load_card("Parsed Shrink {B}\nInstant\nKicker {2}\nTarget creature gets -2/-2 until end of turn. " \
                "If this spell was kicked, that creature gets -5/-5 until end of turn instead.\n")
      shrink = Card("Parsed Shrink", owner: p1)
      bear = ResolvePermanent("Grizzly Bears", owner: p2)
      bear_toughness = bear.toughness

      p1.hand.add(shrink)
      p1.add_mana(black: 1, red: 2)
      p1.cast(card: shrink) do |action|
        action.pay_mana(black: 1).targeting(bear)
        action.pay_kicker(generic: { red: 2 })
      end
      game.stack.resolve!

      expect(bear.toughness).to eq(bear_toughness - 5)
    end

    it "runs untargeted replacement effects" do
      load_card("Parsed Growth {1}{R}\nSorcery\nKicker {2}\nYou gain 3 life. " \
                "If this spell was kicked, instead you gain 8 life.\n")
      go_to_main_phase!

      cast_kicked(Card("Parsed Growth", owner: p1), kicked: true) { _1 }
      expect(p1.life).to eq(28)
    end

    it "gains only the base life when not kicked" do
      load_card("Parsed Growth {1}{R}\nSorcery\nKicker {2}\nYou gain 3 life. " \
                "If this spell was kicked, instead you gain 8 life.\n")
      go_to_main_phase!

      cast_kicked(Card("Parsed Growth", owner: p1), kicked: false) { _1 }
      expect(p1.life).to eq(23)
    end

    it "rejects a replacement with its own target" do
      expect { generate("Parsed Snare {1}{W}\nInstant\nKicker {2}\nDestroy target creature with mana value 3 or less. " \
                        "If this spell was kicked, instead destroy target creature.\n") }
        .to raise_error(Magic::CardParser::UnsupportedCard, /targeted effects after/)
    end

    it "isn't parsed when nothing precedes it" do
      expect { generate("Parsed Snare {1}{W}\nInstant\nKicker {2}\nIf this spell was kicked, instead you gain 8 life.\n") }
        .to raise_error(Magic::CardParser::UnsupportedCard)
    end
  end

  it "cycles for its cycling cost" do
    load_card("Parsed Cycler {3}{U}\nCreature — Bird\nFlying\nCycling {1}{U}\n2/2\n")
    card = Card("Parsed Cycler", owner: p1)
    p1.hand.add(card)
    p1.add_mana(blue: 2)
    top_card = p1.library.first

    p1.cycle(card: card) { _1.pay_mana(generic: { blue: 1 }, blue: 1) }

    expect(card.zone).to be_graveyard
    expect(p1.hand).to include(top_card)
  end

  it "casts from the graveyard for its flashback cost" do
    load_card("Parsed Lesson {1}{R}\nSorcery\nParsed Lesson deals 2 damage to any target.\nFlashback {3}{R}\n")
    lesson = Card("Parsed Lesson", owner: p1)
    lesson.move_to_graveyard!(p1)
    go_to_main_phase!

    p1.add_mana(red: 4)
    action = cast_action(player: p1, card: lesson, flashback: true)
    expect(action.mana_cost).to eq(Magic::Costs::Mana.new(generic: 3, red: 1))
    action.pay_mana(generic: { red: 3 }, red: 1).targeting(p2)
    game.take_action(action)
    game.stack.resolve!

    expect(p2.life).to eq(18)
    expect(lesson.zone).to be_exile
  end
end
