# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Trigger do
  let(:e) { Magic::CardParser::Effects }
  let(:draw) { [e.const_get(:DrawCards).new(1)] }

  def parse(line) = described_class.parse(line)

  it "parses both enters wordings" do
    expect(parse("When ~ enters, draw a card.").effect_list.effects).to eq(draw)
    expect(parse("When ~ enters the battlefield, you gain 3 life.").effect_list.effects).to eq([e.const_get(:GainLife).new(3)])
    expect(parse("When ~ enters, draw a card.").hook).to eq(:etb_triggers)
  end

  it "parses several effects" do
    effects = parse("When ~ enters, scry 2, then draw a card.").effect_list.effects
    expect(effects).to eq([e.const_get(:Scry).new(2), e.const_get(:DrawCards).new(1)])
  end

  it "splits effects joined by \"and you\"" do
    effects = parse("At the beginning of your upkeep, you draw a card and you lose 1 life.").effect_list.effects
    expect(effects).to eq([e.const_get(:DrawCards).new(1), e.const_get(:LoseLife).new("you", 1)])
  end

  it "parses each kind of trigger, with its hook, event and condition" do
    kinds = {
      "When ~ dies, draw a card." => ["DiesTrigger", :death_triggers, nil, nil],
      "Whenever a land you control enters, draw a card." => ["LandfallTrigger", :event_handlers, "Events::Landfall", "you?"],
      "Whenever a land enters the battlefield under your control, draw a card." => ["LandfallTrigger", :event_handlers, "Events::Landfall", "you?"],
      "At the beginning of your upkeep, draw a card." => ["UpkeepTrigger", :event_handlers, "Events::BeginningOfUpkeep", nil],
      "At the beginning of your end step, draw a card." => ["EndStepTrigger", :event_handlers, "Events::BeginningOfEndStep", "controllers_end_step?"],
      "Whenever ~ attacks, draw a card." => ["AttacksTrigger", :event_handlers, "Events::FinalAttackersDeclared", "event.attacks.any? { _1.attacker == actor }"],
      "Whenever another creature you control enters, draw a card." =>
        ["CreatureEntersTrigger", :event_handlers, "Events::EnteredTheBattlefield", "another_creature? && under_your_control?"]
    }
    kinds.each do |line, (name, hook, event, condition)|
      rule = parse(line)
      expect([rule.class_base_name, rule.hook, rule.handled_event, rule.condition]).to eq([name, hook, event, condition]), line
      expect(rule.effect_list.effects).to eq(draw)
    end
  end

  it "adapts the cast trigger to the spell type, with a or an" do
    expect(parse("Whenever you cast a creature spell, draw a card.").condition).to eq('you? && spell.type?("Creature")')
    expect(parse("Whenever you cast an Elf spell, draw a card.").condition).to eq('you? && spell.type?("Elf")')
    expect(parse("Whenever you cast an instant or sorcery spell, draw a card.").condition)
      .to eq('you? && (spell.type?("Instant") || spell.type?("Sorcery"))')
  end

  it "drops an ability word" do
    expect(parse("Landfall — Whenever a land you control enters, you gain 1 life.").class_base_name).to eq("LandfallTrigger")
  end

  it "limits dies and attacks triggers to creatures" do
    expect(parse("When ~ dies, draw a card.").kinds).to eq(%i[creature])
    expect(parse("When ~ enters, draw a card.").kinds).to include(:land, :artifact)
  end

  it "ignores other lines and unknown effects" do
    expect(parse("When ~ leaves the battlefield, draw a card.")).to be_nil
    expect(parse("Whenever you cast a creature spell, you may draw a card.")).to be_nil
    expect(parse("When ~ enters, return target card from your graveyard to your hand.")).to be_nil
  end

  it "renders an untargeted trigger" do
    expect(parse("When ~ enters, draw a card.").class_source("EntersTrigger")).to eq(<<~RUBY)
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end
    RUBY
  end

  it "renders the condition" do
    source = parse("Whenever you cast a creature spell, draw a card.").class_source("SpellCastTrigger")
    expect(source).to include("class SpellCastTrigger < TriggeredAbility::SpellCast",
                              "def should_perform?\n    you? && spell.type?(\"Creature\")\n  end", "trigger_effect(:draw_cards")
  end

  it "chooses targets with a choice, running later effects there too" do
    source = parse("When ~ enters, it deals 2 damage to any target. You gain 1 life.").class_source("EntersTrigger")
    expect(source).to include("class TargetChoice < Magic::Choice::Targeted", "game.any_target",
                              "def resolve!(target:)\n      trigger_effect(:deal_damage, target: target, damage: 2)\n      trigger_effect(:gain_life",
                              "def call\n    choice = TargetChoice.new(actor: actor)\n    game.add_choice(choice) if choice.choices.any?")
  end

  it "rejects a target and a scry in one trigger" do
    expect { parse("When ~ enters, scry 1. Destroy target creature.").class_source("X") }
      .to raise_error(Magic::CardParser::UnsupportedCard)
  end
end
