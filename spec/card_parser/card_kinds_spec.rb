# frozen_string_literal: true

require "spec_helper"

RSpec.describe "CardParser card kinds" do
  def generate(text)
    Magic::CardGenerator.generate(Magic::CardParser.parse(text))
  end

  def load_card(text)
    name = text.lines.first[/\A[^{\n]+/].strip
    const = Magic::CardGenerator.const_name(name)
    Magic::Cards.send(:remove_const, const) if Magic::Cards.const_defined?(const, false)
    # rubocop:disable Security/Eval
    eval(generate(text))
    # rubocop:enable Security/Eval
    Magic::Cards.const_get(const)
  end

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

  it "generates a saga" do
    expect(generate("Old Tale {2}{G}\nEnchantment — Saga\n")).to include('Saga("Old Tale")')
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

    it "resolves a generated equipment with an equip ability" do
      load_card("Parsed Blade {1}\nArtifact — Equipment\nEquip {1}\n")
      blade = ResolvePermanent("Parsed Blade", owner: p1)
      expect(blade.card.types).to include("Artifact", "Equipment")
      expect(blade.activated_abilities.size).to eq(1)
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
