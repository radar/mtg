# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser double-faced cards" do
  include CardParserHelpers
  include_context "two player game"

  let(:trystan_text) do
    <<~TEXT
      Parsed Trystan, Callous Cultivator {2}{G}
      Legendary Creature — Elf Druid
      Deathtouch
      Whenever this creature enters or transforms into Parsed Trystan, Callous Cultivator, mill three cards. Then if there is an Elf card in your graveyard, you gain 2 life.
      At the beginning of your first main phase, you may pay {B}. If you do, transform Parsed Trystan.
      3/4
      ----
      Parsed Trystan, Penitent Culler
      Color Indicator: Black
      Legendary Creature — Elf Warlock
      Deathtouch
      Whenever this creature transforms into Parsed Trystan, Penitent Culler, mill three cards, then you may exile an Elf card from your graveyard. If you do, each opponent loses 2 life.
      At the beginning of your first main phase, you may pay {G}. If you do, transform Parsed Trystan.
      3/4
    TEXT
  end

  describe "parsing" do
    it "parses the two faces separated by ----" do
      result = Magic::CardParser.parse(trystan_text)

      expect(result.name).to eq("Parsed Trystan, Callous Cultivator")
      expect(result.back_face.name).to eq("Parsed Trystan, Penitent Culler")
      expect(result.back_face.mana_cost).to eq({})
      expect(result.back_face.subtypes).to eq(%w[Elf Warlock])
    end

    it "reads the back face's colour indicator" do
      expect(Magic::CardParser.parse(trystan_text).back_face.color_indicator).to eq([:black])
    end

    it "leaves a single-faced card alone" do
      result = Magic::CardParser.parse("Aegis Turtle {U}\nCreature — Turtle\n0/5\n")

      expect(result.back_face).to be_nil
      expect(result.color_indicator).to be_nil
    end

    it "accepts several colours in the indicator" do
      result = Magic::CardParser.parse("Front {1}\nCreature — Elf\n1/1\n----\nBack\nColor Indicator: Blue and Red\nCreature — Elf\n1/1\n")

      expect(result.back_face.color_indicator).to eq(%i[blue red])
    end

    it "rejects an unknown colour" do
      expect { Magic::CardParser.parse("Front {1}\nCreature — Elf\n1/1\n----\nBack\nColor Indicator: Purple\nCreature — Elf\n1/1\n") }
        .to raise_error(Magic::CardParser::UnsupportedCard, /purple/)
    end

    it "calls a legendary face by its first name in its rules text" do
      rule = Magic::CardParser.parse(trystan_text).rules.grep(Magic::CardParser::Rules::PayToTransform).first

      expect(rule.mana).to eq({ black: 1 })
    end
  end

  describe "generating" do
    it "writes the back face's class first, then the front face naming it" do
      source = Magic::CardGenerator.generate(Magic::CardParser.parse(trystan_text))

      expect(source.index("ParsedTrystanPenitentCuller = Creature")).to be < source.index("ParsedTrystanCallousCultivator = Creature")
      expect(source).to include("back_face ParsedTrystanPenitentCuller", "color_indicator :black")
      expect(source).to include("class PayToTransformTrigger < TriggeredAbility::PayToTransform", "pay black: 1", "pay green: 1")
    end

    it "gives the front both an enters and a transforms-into trigger, the back only the latter" do
      source = Magic::CardGenerator.generate(Magic::CardParser.parse(trystan_text))
      front = source[source.index("ParsedTrystanCallousCultivator = Creature")..]
      back = source[0...source.index("ParsedTrystanCallousCultivator = Creature")]

      expect(front).to include("def etb_triggers", "Events::PermanentTransformed => TransformedTrigger")
      expect(back).to include("Events::PermanentTransformed => TransformedTrigger")
      expect(back).not_to include("etb_triggers")
    end

    it "refuses a non-creature double-faced card" do
      text = "Front {1}\nSorcery\nDraw a card.\n----\nBack\nSorcery\nDraw a card.\n"

      expect { Magic::CardGenerator.generate(Magic::CardParser.parse(text)) }.to raise_error(Magic::CardParser::UnsupportedCard)
    end
  end

  describe "in play" do
    before do
      go_to_main_phase!
      8.times { p1.library.add(Card("Forest", owner: p1)) }
      load_card(trystan_text)
    end

    let(:trystan) { ResolvePermanent("Parsed Trystan, Callous Cultivator", owner: p1) }

    def first_main_phase!
      game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
      game.settle!
    end

    it "is a 3/4 deathtouch Elf Druid that mills three when it enters" do
      expect { trystan }.to change { p1.library.count }.by(-3)
      expect([trystan.power, trystan.toughness]).to eq([3, 4])
      expect(trystan).to be_deathtouch
      expect(trystan.card).to be_double_faced
    end

    it "gains 2 life when an Elf card is in the graveyard" do
      p1.graveyard.add(Card("Skyway Sniper", owner: p1))

      expect { trystan }.to change { p1.life }.by(2)
    end

    it "may pay {B} at the beginning of your first main phase to transform" do
      trystan
      p1.add_mana(black: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(trystan.transformed?).to be(true)
      expect(trystan.name).to eq("Parsed Trystan, Penitent Culler")
      expect(trystan.colors).to eq([:black])
      expect(trystan.mana_value).to eq(3)
    end

    it "the back face mills three when transformed into, and may exile an Elf card to drain each opponent" do
      trystan
      elf = Card("Skyway Sniper", owner: p1)
      p1.graveyard.add(elf)
      library = p1.library.count
      trystan.transform!
      game.settle!
      game.resolve_choice! # yes, exile an Elf card
      game.resolve_choice!(target: elf)

      expect(p1.library.count).to eq(library - 3)
      expect(elf.zone).to be_exile
      expect(p2.life).to eq(18)
    end

    it "the back face does nothing more when there is no Elf card to exile" do
      trystan
      trystan.transform!
      game.settle!
      game.resolve_choice!

      expect(game.choices).to be_empty
      expect(p2.life).to eq(20)
    end

    it "may pay {G} to transform back" do
      trystan
      trystan.transform!
      game.settle!
      game.skip_choice! if game.choices.any?
      p1.add_mana(green: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(trystan.transformed?).to be(false)
      expect(trystan.name).to eq("Parsed Trystan, Callous Cultivator")
    end
  end
end
