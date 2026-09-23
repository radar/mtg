# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser do
  let(:text) do
    <<~TEXT
      Aegis Turtle {U}
      Creature — Turtle

      0/5
    TEXT
  end

  it "parses a vanilla creature" do
    result = described_class.parse(text)
    expect(result.name).to eq("Aegis Turtle")
    expect(result.mana_cost).to eq(blue: 1)
    expect(result.types).to eq(["Creature"])
    expect(result.subtypes).to eq(["Turtle"])
    expect(result.power).to eq(0)
    expect(result.toughness).to eq(5)
  end

  it "parses generic and multiple colours, and legendary" do
    result = described_class.parse("Some Guy {2}{W}{W}\nLegendary Creature — Human Cleric\n2/3")
    expect(result.mana_cost).to eq(generic: 2, white: 2)
    expect(result.legendary?).to eq(true)
    expect(result.subtypes).to eq(%w[Human Cleric])
  end

  it "parses keywords" do
    result = described_class.parse("Sky Bear {1}{G}\nCreature — Bear\nFlying, first strike\nTrample\n2/2")
    expect(result.keywords).to eq(%i[flying first_strike trample])
    expect(Magic::CardGenerator.generate(result)).to include("keywords :flying, :first_strike, :trample")
  end

  it "defaults to no keywords" do
    expect(described_class.parse(text).keywords).to eq([])
  end

  it "rejects other rules text" do
    expect { described_class.parse("Bear {1}{G}\nCreature — Bear\nWhen Bear leaves the battlefield, draw a card.\n2/2") }
      .to raise_error(described_class::UnsupportedCard)
  end

  it "generates card source" do
    source = Magic::CardGenerator.generate(described_class.parse(text))
    expect(source).to include('AegisTurtle = Creature("Aegis Turtle") do')
    expect(source).to include("cost blue: 1")
    expect(source).to include('creature_type("Turtle")')
  end
  describe "abilities" do
    let(:tactician) do
      <<~TEXT
        Canopy Tactician {3}{G}
        Creature — Elf Warrior
        Other Elves you control get +1/+1.
        {T}: Add {G}{G}{G}.
        3/3
      TEXT
    end

    it "parses a tribal lord and a tap mana ability" do
      lord, mana = described_class.parse(tactician).abilities
      expect(lord).to be_a(described_class::Rules::TribalLord)
      expect(mana).to be_a(described_class::Rules::TapForMana)
    end

    it "rejects rules text no rule recognises" do
      expect { described_class.parse("Bear {1}{G}\nCreature — Bear\nWhen Bear leaves the battlefield, draw a card.\n2/2") }
        .to raise_error(described_class::UnsupportedCard)
    end

    it "combines with keywords" do
      result = described_class.parse("Lord {1}{G}\nCreature — Elf\nHaste\n{T}: Add {C}.\n1/1")
      expect(result.keywords).to eq([:haste])
      expect(result.abilities).to eq([described_class::Rules::TapForMana.new({ colorless: 1 })])
    end

    it "generates a card that behaves like the hand-written one" do
      source = Magic::CardGenerator.generate(described_class.parse(tactician))
      expect(source).to include('other_creatures "Elf"')
      expect(source).to include("modify power: 1, toughness: 1")
      expect(source).to include("add_mana(green: 3)")
      expect(source).to include("class CanopyTactician < Creature")
    end

    context "when the generated card is loaded" do
      include_context "two player game"

      before do
        next if Magic::Cards.const_defined?(:ParsedGoblinChief)

        text = "Parsed Goblin Chief {1}{R}\nCreature — Goblin\nOther Goblins you control get +1/+1.\n{T}: Add {R}{R}.\n2/2"
        # rubocop:disable Security/Eval
        eval(Magic::CardGenerator.generate(described_class.parse(text)))
        # rubocop:enable Security/Eval
      end

      it "buffs other members of the chosen type only" do
        chief = ResolvePermanent("Parsed Goblin Chief", owner: p1)
        other_goblin = ResolvePermanent("Mogg Fanatic", owner: p1)
        opponents_goblin = ResolvePermanent("Mogg Fanatic", owner: p2)
        game.tick!

        expect(other_goblin.power).to eq(2)
        expect(opponents_goblin.power).to eq(1)
        expect(chief.power).to eq(2)
      end

      it "taps for mana" do
        chief = ResolvePermanent("Parsed Goblin Chief", owner: p1)
        p1.activate_ability(ability: chief.activated_abilities.first)
        expect(p1.mana_pool[:red]).to eq(2)
      end
    end

    context "when a generated spell-cast trigger is loaded" do
      include_context "two player game"
      before { go_to_main_phase! }

      before do
        next if Magic::Cards.const_defined?(:ParsedElfWatcher)

        text = "Parsed Elf Watcher {1}{G}\nCreature — Elf\nWhenever you cast an Elf spell, draw a card.\n1/1"
        # rubocop:disable Security/Eval
        eval(Magic::CardGenerator.generate(described_class.parse(text)))
        # rubocop:enable Security/Eval
      end

      it "draws only for spells of the chosen type" do
        ResolvePermanent("Parsed Elf Watcher", owner: p1)
        draws = -> { game.current_turn.events.count { _1.is_a?(Magic::Events::CardDraw) && _1.player == p1 } }

        elf = Card("Elvish Mystic", owner: p1)
        p1.hand.add(elf)
        p1.add_mana(green: 1)
        expect { p1.cast(card: elf) { |a| a.pay_mana(green: 1) } }.to change { draws.call }.by(1)
      end
    end

    context "when a generated per-creature mana ability is loaded" do
      include_context "two player game"

      before do
        next if Magic::Cards.const_defined?(:ParsedCreatureDruid)

        text = "Parsed Creature Druid {G}\nCreature — Elf Druid\n{T}: Add {G} for each creature you control.\n1/1"
        # rubocop:disable Security/Eval
        eval(Magic::CardGenerator.generate(described_class.parse(text)))
        # rubocop:enable Security/Eval
      end

      it "adds one mana per creature you control" do
        druid = ResolvePermanent("Parsed Creature Druid", owner: p1)
        ResolvePermanent("Elvish Mystic", owner: p1)
        ResolvePermanent("Elvish Mystic", owner: p2)
        p1.activate_ability(ability: druid.activated_abilities.first)
        expect(p1.mana_pool[:green]).to eq(2)
      end
    end
  end
end
