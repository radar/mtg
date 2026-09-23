# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser card kinds" do
  include CardParserHelpers

  it "generates an instant with its effect" do
    source = generate("Lightning Bolt {R}\nInstant\nLightning Bolt deals 3 damage to any target.\n")
    expect(source).to include('LightningBolt = Instant("Lightning Bolt") do', "cost red: 1", "class LightningBolt < Instant",
                              "game.any_target", "trigger_effect(:deal_damage, target: target, damage: 3)")
  end

  it "generates a sorcery, enchantment and artifact" do
    expect(generate("Rite {1}{B}\nSorcery\nYou gain 3 life.\n")).to include('Sorcery("Rite")', "trigger_effect(:gain_life")
    expect(generate("Aura Of Calm {2}{W}\nEnchantment\n")).to include('Enchantment("Aura Of Calm")')
    expect(generate("Baubles {2}\nArtifact\n")).to include('Artifact("Baubles")')
  end

  it "requires an effect on instants and sorceries" do
    expect { generate("Zap {R}\nInstant\n") }.to raise_error(Magic::CardParser::ParseError, /SpellEffect/)
  end

  it "rejects spell effects on other kinds" do
    expect { generate("Baubles {2}\nArtifact\nDraw a card.\n") }.to raise_error(Magic::CardParser::UnsupportedCard)
  end

  it "generates a legendary artifact" do
    expect(generate("Old Shiny {3}\nLegendary Artifact\n")).to include("legendary_artifact")
  end

  it "generates an artifact creature" do
    expect(generate("Wall Bot {2}\nArtifact Creature — Construct\nDefender\n0/4\n")).to include('artifact_creature_type("Construct")')
  end

  it "generates equipment with its equip cost" do
    source = generate("Sword {3}\nArtifact — Equipment\nEquip {2}{R}\n")
    expect(source).to include('Equipment("Sword")', "equip [Costs::Mana.new(generic: 2, red: 1)]")
  end

  it "generates an aura with its enchant restriction" do
    source = generate("Big Rune {1}{R}\nEnchantment — Aura\nEnchant creature you control\n")
    expect(source).to include('Aura("Big Rune")', 'enchant "Creature", you_control: true', "battlefield.controlled_by(controller).creatures")
  end

  it "generates a saga with its chapters" do
    source = generate("Old Tale {2}{G}\nEnchantment — Saga\n(Reminder.)\nI — Draw a card.\nII — You gain 2 life.\n")
    expect(source).to include('Saga("Old Tale")', "class OldTale < Saga", "class Chapter2 < Saga::ChapterAbility", "[Chapter1, Chapter2]")
  end

  it "generates token definitions for spells" do
    expect(generate("Raise {W}\nSorcery\nCreate a 1/1 white Soldier creature token.\n")).to include("SoldierToken = Token.create")
  end

  it "generates a land with a mana ability" do
    source = generate("Quiet Grove\nLand\n{T}: Add {G}.\n")
    expect(source).to include("class QuietGrove < Land", 'NAME = "Quiet Grove"', "add_mana(green: 1)")
  end

  it "generates a basic land, ignoring reminder text" do
    expect(generate("Island\nBasic Land — Island\n({T}: Add {U}.)\n")).to include("class Island < BasicLand", "type Types::Lands::Island")
  end

  it "requires equip and enchant lines" do
    expect { generate("Sword {3}\nArtifact — Equipment\n") }.to raise_error(Magic::CardParser::ParseError, /Equip/)
    expect { generate("Rune {1}\nEnchantment — Aura\n") }.to raise_error(Magic::CardParser::ParseError, /Enchant/)
    expect { generate("Old Tale {1}\nEnchantment — Saga\n") }.to raise_error(Magic::CardParser::ParseError, /Chapter/)
  end

  it "rejects chapters outside sagas" do
    expect { generate("Baubles {2}\nEnchantment\nI — Draw a card.\n") }.to raise_error(Magic::CardParser::UnsupportedCard, /Chapter/)
  end

  it "rejects unsupported type lines" do
    expect { generate("Thing {1}\nArtifact — Food\n") }.to raise_error(Magic::CardParser::UnsupportedCard)
    expect { generate("Thing {1}\nLegendary Enchantment\n") }.to raise_error(Magic::CardParser::UnsupportedCard)
  end

  context "when the generated cards are loaded" do
    include_context "two player game"

    it "casts a generated Lightning Bolt at a player" do
      load_card("Parsed Bolt {R}\nInstant\nParsed Bolt deals 3 damage to any target.\n")
      bolt = Card("Parsed Bolt", owner: p1)
      p1.hand.add(bolt)
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p2) }
      game.stack.resolve!
      expect(p2.life).to eq(17)
    end

    it "puts a generated land on the battlefield and taps it for mana" do
      load_card("Parsed Grove\nLand\n{T}: Add {G}.\n")
      land = ResolvePermanent("Parsed Grove", owner: p1)
      p1.activate_ability(ability: land.activated_abilities.first)
      expect(p1.mana_pool[:green]).to eq(1)
    end

    it "plays a generated tapped tri-land that taps for a chosen colour" do
      go_to_main_phase!
      load_card("Parsed Shrine\nLand\nParsed Shrine enters tapped.\n{T}: Add {R}, {G}, or {W}.\n")
      p1.play_land(land: Card("Parsed Shrine", owner: p1))
      shrine = p1.permanents.by_name("Parsed Shrine").first
      expect(shrine).to be_tapped

      shrine.untap!
      p1.activate_ability(ability: shrine.activated_abilities.first) { _1.choose(:white) }
      expect(p1.mana_pool[:white]).to eq(1)
    end

    it "resolves a generated equipment with an equip ability" do
      load_card("Parsed Blade {1}\nArtifact — Equipment\nEquip {1}\n")
      blade = ResolvePermanent("Parsed Blade", owner: p1)
      expect(blade.card.types).to include("Artifact", "Equipment")
      expect(blade.activated_abilities.size).to eq(1)
    end

    it "resolves a generated saga's chapters, including a targeted one" do
      load_card("Parsed Tale {1}\nEnchantment — Saga\nI — Create a 2/2 green Wolf creature token.\nII — Parsed Tale deals 3 damage to any target.\n")
      saga = ResolvePermanent("Parsed Tale", owner: p1)
      expect(game.battlefield.creatures.by_name("Wolf").map(&:power)).to eq([2])

      saga.trigger_effect(:add_counter, counter_type: "lore", target: saga)
      game.resolve_choice!(target: p2)
      expect(p2.life).to eq(17)
      expect(saga.card.zone).to be_graveyard
    end

    it "restricts a generated aura to creatures you control" do
      aura_class = load_card("Parsed Rune {1}\nEnchantment — Aura\nEnchant creature you control\n")
      aura = aura_class.new(game: game, owner: p1)
      mine = ResolvePermanent("Elvish Mystic", owner: p1)
      theirs = ResolvePermanent("Elvish Mystic", owner: p2)

      expect(aura.can_enchant?(mine, aura: aura)).to eq(true)
      expect(aura.can_enchant?(theirs, aura: aura)).to eq(false)
    end
  end
end
