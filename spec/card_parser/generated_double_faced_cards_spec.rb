# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

# The Lorwyn Eclipsed double-faced cards, generated from their Oracle text (under other names so
# the hand-written cards stay loaded).
RSpec.describe "CardParser generated double-faced cards in play" do
  include CardParserHelpers
  include_context "two player game"
  before { go_to_main_phase! }

  def first_main_phase!
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
    game.settle!
  end

  describe "Grub" do
    let(:text) do
      <<~TEXT
        Parsed Grub, Storied Matriarch {2}{B}
        Legendary Creature — Goblin Warlock
        Menace
        Whenever this creature enters or transforms into Parsed Grub, Storied Matriarch, return up to one target Goblin card from your graveyard to your hand.
        At the beginning of your first main phase, you may pay {R}. If you do, transform Parsed Grub.
        2/1
        ----
        Parsed Grub, Notorious Auntie
        Color Indicator: Red
        Legendary Creature — Goblin Warrior
        Menace
        Whenever Parsed Grub attacks, you may blight 1. If you do, create a tapped and attacking token that's a copy of the blighted creature, except it has "At the beginning of the end step, sacrifice this token."
        At the beginning of your first main phase, you may pay {B}. If you do, transform Parsed Grub.
        2/1
      TEXT
    end

    before { load_card(text) }

    it "returns up to one Goblin card from your graveyard when it enters" do
      goblin = Card("Boneclub Berserker", owner: p1)
      p1.graveyard.add(goblin)
      ResolvePermanent("Parsed Grub, Storied Matriarch", owner: p1)
      game.resolve_choice!(target: goblin)

      expect(goblin.zone).to be_hand
    end

    it "may return nothing" do
      goblin = Card("Boneclub Berserker", owner: p1)
      p1.graveyard.add(goblin)
      ResolvePermanent("Parsed Grub, Storied Matriarch", owner: p1)
      game.skip_choice!

      expect(goblin.zone).to be_graveyard
    end

    it "transforms for {R}, and the back face blights to copy a creature as it attacks" do
      grub = ResolvePermanent("Parsed Grub, Storied Matriarch", owner: p1)
      p1.add_mana(red: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)
      expect(grub.name).to eq("Parsed Grub, Notorious Auntie")

      courser = ResolvePermanent("Courser Of Kruphix", owner: p1)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(grub, target: p2)
      current_turn.attackers_declared!
      game.settle!
      game.resolve_choice! # yes, blight 1
      game.resolve_choice!(target: courser)
      copy = p1.creatures.find { _1.token? && _1.name == "Courser of Kruphix" }

      expect(courser.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
      expect(copy).to be_tapped
      expect(current_turn.attacking?(copy)).to be(true)
    end

    it "sacrifices that token at the beginning of the end step" do
      grub = ResolvePermanent("Parsed Grub, Storied Matriarch", owner: p1)
      grub.transform!
      game.settle!
      courser = ResolvePermanent("Courser Of Kruphix", owner: p1)
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(grub, target: p2)
      current_turn.attackers_declared!
      game.settle!
      game.resolve_choice!
      game.resolve_choice!(target: courser)
      copy = p1.creatures.find(&:token?)
      current_turn.end!
      game.settle!

      expect(p1.creatures).not_to include(copy)
    end
  end

  describe "Brigid" do
    let(:text) do
      <<~TEXT
        Parsed Brigid, Clachan's Heart {2}{W}
        Legendary Creature — Kithkin Warrior
        Whenever this creature enters or transforms into Parsed Brigid, Clachan's Heart, create a 1/1 green and white Kithkin creature token.
        At the beginning of your first main phase, you may pay {G}. If you do, transform Parsed Brigid.
        3/2
        ----
        Parsed Brigid, Doun's Mind
        Color Indicator: Green
        Legendary Creature — Kithkin Soldier
        {T}: Add X {G} or X {W}, where X is the number of other creatures you control.
        At the beginning of your first main phase, you may pay {W}. If you do, transform Parsed Brigid.
        3/2
      TEXT
    end

    before { load_card(text) }

    it "creates a Kithkin token when it enters" do
      ResolvePermanent("Parsed Brigid, Clachan's Heart", owner: p1)

      expect(p1.creatures.map(&:name)).to include("Kithkin")
    end

    it "the back face taps for X mana of one colour, X being your other creatures" do
      brigid = ResolvePermanent("Parsed Brigid, Clachan's Heart", owner: p1)
      brigid.transform!
      game.settle!
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p2)
      p1.activate_ability(ability: brigid.activated_abilities.first) { _1.choose(:white) }

      expect(p1.mana_pool[:white]).to eq(2) # the Kithkin token and the Bears
    end
  end

  describe "Ashling" do
    let(:text) do
      <<~TEXT
        Parsed Ashling, Rekindled {1}{R}
        Legendary Creature — Elemental Sorcerer
        Whenever this creature enters or transforms into Parsed Ashling, Rekindled, you may discard a card. If you do, draw a card.
        At the beginning of your first main phase, you may pay {U}. If you do, transform Parsed Ashling.
        1/3
        ----
        Parsed Ashling, Rimebound
        Color Indicator: Blue
        Legendary Creature — Elemental Wizard
        Whenever this creature transforms into Parsed Ashling, Rimebound and at the beginning of your first main phase, add two mana of any one color. Spend this mana only to cast spells with mana value 4 or greater.
        At the beginning of your first main phase, you may pay {R}. If you do, transform Parsed Ashling.
        1/3
      TEXT
    end

    before { load_card(text) }

    it "may loot when it enters" do
      ResolvePermanent("Parsed Ashling, Rekindled", owner: p1)
      game.resolve_choice!
      card = p1.hand.cards.first
      hand = p1.hand.count
      game.resolve_choice!(card:)

      expect(card.zone).to be_graveyard
      expect(p1.hand.count).to eq(hand)
    end

    it "the back face adds two restricted mana of one colour when it transforms, and each first main phase" do
      ashling = ResolvePermanent("Parsed Ashling, Rekindled", owner: p1)
      game.skip_choice!
      ashling.transform!
      game.settle!
      game.resolve_choice!(color: :red)

      expect(p1.restricted_mana.map(&:color)).to eq(%i[red red])
      first_main_phase!
      game.resolve_choice!(color: :red) if game.choices.first.is_a?(Magic::Choice::Color)

      expect(p1.restricted_mana.size).to be >= 4
      restriction = p1.restricted_mana.first.restriction
      expect(restriction.permits?(Card("Sunderflock", owner: p1))).to be(true)
      expect(restriction.permits?(Card("Grizzly Bears", owner: p1))).to be(false)
    end
  end

  describe "Eirdu" do
    let(:text) do
      <<~TEXT
        Parsed Eirdu, Carrier of Dawn {3}{W}{W}
        Legendary Creature — Elemental God
        Flying, lifelink
        Creature spells you cast have convoke.
        At the beginning of your first main phase, you may pay {B}. If you do, transform Parsed Eirdu.
        5/5
        ----
        Parsed Isilu, Carrier of Twilight
        Color Indicator: Black
        Legendary Creature — Elemental God
        Flying, lifelink
        Each other nontoken creature you control has persist.
        At the beginning of your first main phase, you may pay {W}. If you do, transform Parsed Eirdu.
        5/5
      TEXT
    end

    before { load_card(text) }

    it "gives your creature spells convoke" do
      ResolvePermanent("Parsed Eirdu, Carrier of Dawn", owner: p1)
      helper = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Courser Of Kruphix", owner: p1)
      p1.hand.add(spell)
      p1.add_mana(green: 2)
      p1.cast(card: spell) do |action|
        action.convoke(helper)
        action.pay_mana(green: 2)
      end

      expect(helper).to be_tapped
    end

    it "the back face gives each other nontoken creature you control persist" do
      eirdu = ResolvePermanent("Parsed Eirdu, Carrier of Dawn", owner: p1)
      eirdu.transform!
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      game.tick!

      expect(bears).to be_persist
      expect(eirdu).not_to be_persist
    end
  end
end
