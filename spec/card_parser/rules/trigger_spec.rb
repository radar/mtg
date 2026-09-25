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

  it "parses the combat, end step, attack and counter triggers" do
    kinds = {
      "Whenever ~ deals combat damage to a player, draw a card." =>
        ["CombatDamageTrigger", "Events::CombatDamageDealt", "event.source == actor && event.target.is_a?(Magic::Player)"],
      "At the beginning of combat on your turn, draw a card." =>
        ["BeginningOfCombatTrigger", "Events::BeginningOfCombat", "event.active_player == controller"],
      "At the beginning of each end step, draw a card." => ["EachEndStepTrigger", "Events::BeginningOfEndStep", nil],
      "Whenever you attack, draw a card." =>
        ["YouAttackTrigger", "Events::FinalAttackersDeclared", "event.active_player == controller && event.attacks.any?"],
      "When the last time counter is removed from ~, draw a card." =>
        ["LastCounterRemovedTrigger", "Events::CounterRemoved",
         "event.permanent == actor && Counters[event.counter_type] == Counters::Time && actor.counters.of_type(Counters::Time).none?"]
    }
    kinds.each do |line, (name, event, condition)|
      rule = parse(line)
      expect([rule.class_base_name, rule.handled_event, rule.condition]).to eq([name, event, condition]), line
    end
    expect(parse("When the last widget counter is removed from ~, draw a card.")).to be_nil
  end

  it "parses creatures being exiled from the battlefield" do
    rule = parse("Whenever a creature is exiled from the battlefield, put a +1/+1 counter on ~.")
    expect([rule.class_base_name, rule.handled_event, rule.condition])
      .to eq(["CreatureExiledTrigger", "Events::LeftTheBattlefield", "event.permanent.creature? && event.to.exile?"])
    expect(parse("Whenever another creature is exiled from the battlefield, draw a card.").condition)
      .to end_with("&& event.permanent != actor")
  end

  it "keeps a one-effect sentence with \", then\" together, and splits two effects" do
    one = parse("At the beginning of your end step, you may exile another target creature you control, " \
                "then return that card to the battlefield under its owner's control.").effect_list.effects
    expect(one.map(&:class)).to eq([Magic::CardParser::OptionalEffect])
    expect(one.first.effect).to be_a(Magic::CardParser::Effects::Flicker)
    expect(parse("When ~ enters, draw a card, then discard a card.").effect_list.effects.size).to eq(2)
  end

  it "treats When and Whenever alike" do
    expect(parse("Whenever ~ enters, draw a card.").class_base_name).to eq("EntersTrigger")
    expect(parse("When ~ attacks, draw a card.").class_base_name).to eq("AttacksTrigger")
  end

  it "splits enters-or-attacks into an enters trigger and an attacks trigger" do
    rules = described_class.merge([parse("Whenever ~ enters or attacks, draw a card.")])
    expect(rules.map { [_1.class_base_name, _1.hook, _1.condition] }).to eq(
      [["EntersTrigger", :etb_triggers, nil], ["AttacksTrigger", :event_handlers, "event.attacks.any? { _1.attacker == actor }"]]
    )
    expect(rules.map(&:effect_list).uniq.size).to eq(1)
  end

  it "splits enters-or-dies into an enters trigger and a dies trigger" do
    rules = described_class.merge([parse("When ~ enters or dies, draw a card.")])
    expect(rules.map { [_1.class_base_name, _1.hook] }).to eq([["EntersTrigger", :etb_triggers], ["DiesTrigger", :death_triggers]])
    expect(rules.map(&:effect_list).uniq.size).to eq(1)
  end

  it "doesn't parse face-down triggers, which the engine can't do" do
    expect(parse("When ~ is turned face up, draw a card.")).to be_nil
  end

  it "parses leaves-the-battlefield triggers" do
    rule = parse("When ~ leaves the battlefield, draw a card.")
    expect([rule.class_base_name, rule.hook]).to eq(["LeavesTrigger", :ltb_triggers])
  end

  it "parses creatures dying, by whose creature it is" do
    conditions = {
      "a creature" => nil,
      "another creature" => "event.permanent != actor",
      "a creature you control" => "you?",
      "another creature you control" => "you? && event.permanent != actor",
      "a creature an opponent controls" => "opponent?"
    }
    conditions.each do |who, condition|
      rule = parse("Whenever #{who} dies, draw a card.")
      expect([rule.class_base_name, rule.handled_event, rule.condition]).to eq(["CreatureDiesTrigger", "Events::CreatureDied", condition]), who
    end
  end

  it "parses life gain, by who gains the life" do
    { "you gain" => "you?", "an opponent gains" => "opponent?", "a player gains" => nil }.each do |who, condition|
      rule = parse("Whenever #{who} life, each opponent loses 1 life.")
      expect([rule.class_base_name, rule.handled_event, rule.condition]).to eq(["LifeGainTrigger", "Events::LifeGain", condition]), who
    end
  end

  it "parses the beginning of your first main phase" do
    rule = parse("At the beginning of your first main phase, draw a card.")
    expect([rule.class_base_name, rule.handled_event, rule.condition])
      .to eq(["MainPhaseTrigger", "Events::FirstMainPhase", "event.active_player == controller"])
  end

  it "runs \"If you don't\" effects when an optional effect is declined, and \"When you do\" like \"If you do\"" do
    list = described_class.parse("At the beginning of your upkeep, you may blight 2. If you don't, you lose 3 life.").effect_list
    optional = list.effects.first
    expect(optional).to be_a(Magic::CardParser::OptionalEffect)
    expect(optional.if_you_dont).to eq([Magic::CardParser::Effects::LoseLife.new("you", 3)])

    source = described_class.parse("At the beginning of your upkeep, you may blight 2. When you do, draw a card.").effect_list.trigger_source
    expect(source).to include("class BlightChoice < Magic::Choice::Blight", "trigger_effect(:draw_cards")
  end

  it "parses creature-type-qualified dies triggers" do
    another = parse("Whenever another Goblin you control dies, draw a card.")
    expect([another.class_base_name, another.handled_event, another.condition])
      .to eq(["TribalDiesTrigger", "Events::CreatureDied", 'you? && event.permanent != actor && event.permanent.type?("Goblin")'])
    expect(parse("Whenever another Elf or Faerie you control dies, draw a card.").condition).to include('(event.permanent.type?("Elf") || event.permanent.type?("Faerie"))')
    expect(parse("Whenever a Goblin creature you control dies, draw a card.").condition).to eq('you? && event.permanent.type?("Goblin")')
    expect(parse("Whenever another Widget you control dies, draw a card.")).to be_nil
  end

  it "parses creature-type-qualified enters triggers, with and without ~" do
    another = parse("Whenever another Kithkin you control enters, draw a card.")
    expect([another.class_base_name, another.handled_event, another.condition])
      .to eq(["TribalEntersTrigger", "Events::EnteredTheBattlefield", 'under_your_control? && event.permanent != actor && event.permanent.type?("Kithkin")'])
    expect(parse("Whenever ~ or another Kithkin you control enters, draw a card.").condition)
      .to eq('under_your_control? && (event.permanent == actor || event.permanent.type?("Kithkin"))')
  end

  it "parses becoming tapped" do
    rule = parse("Whenever ~ becomes tapped, draw a card.")
    expect([rule.class_base_name, rule.handled_event, rule.condition]).to eq(["BecomesTappedTrigger", "Events::PermanentTapped", "event.permanent == actor"])
  end

  it "negates non<type> spells" do
    expect(parse("Whenever you cast a noncreature spell, draw a card.").condition).to eq('you? && !spell.type?("Creature")')
  end

  it "wraps an optional effect in a MayChoice" do
    source = parse("Whenever you cast a creature spell, you may draw a card.").class_source("SpellCastTrigger")
    expect(source).to include("class MayChoice < Magic::Choice::May\n    def resolve!\n      trigger_effect(:draw_cards",
                              "def call\n    game.choices.add(MayChoice.new(actor: actor))")
  end

  it "asks before choosing targets for an optional targeted effect" do
    source = parse("When ~ enters, you may destroy target artifact.").class_source("EntersTrigger")
    expect(source).to include("class MayChoice < Magic::Choice::May\n    class TargetChoice < Magic::Choice::Targeted",
                              "def resolve!\n      choice = TargetChoice.new(actor: actor)",
                              "def call\n    return if battlefield.artifacts.none?\n    game.choices.add(MayChoice.new(actor: actor))")
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
    expect(parse("Whenever ~ becomes blocked, draw a card.")).to be_nil
    expect(parse("Whenever you cast a creature spell, if you do, draw a card.")).to be_nil
    expect(parse("When ~ enters, return target creature to its owner's hand.")).to be_nil
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

  it "parses casting a spell during an opponent's turn" do
    source = parse("Whenever you cast a spell during an opponent's turn, draw a card.").class_source("OpponentsTurnSpellCastTrigger")
    expect(source).to include("class OpponentsTurnSpellCastTrigger < TriggeredAbility::SpellCast",
                              "def should_perform?\n    you? && !controllers_turn?\n  end")
  end

  it "parses an end step trigger conditional on another creature having entered" do
    source = parse("At the beginning of your end step, if another creature entered the battlefield under your control this turn, draw a card.")
      .class_source("EndStepIfCreatureEnteredTrigger")
    expect(source).to include("class EndStepIfCreatureEnteredTrigger < TriggeredAbility::BeginningOfEndStep",
                              "controllers_end_step? && game.current_turn.events.any?", "trigger_effect(:draw_cards")
  end

  it "parses an each-end-step trigger conditional on you having put a counter on a creature" do
    source = parse("At the beginning of each end step, if you put a counter on a creature this turn, ~ deals 2 damage to each opponent.")
      .class_source("EachEndStepIfCounterPutTrigger")
    expect(source).to include("class EachEndStepIfCounterPutTrigger < TriggeredAbility::BeginningOfEndStep",
                              "Events::CounterAddedToPermanent", "e.source&.controller == controller")
  end

  it "chooses targets with a choice, running later effects there too" do
    source = parse("When ~ enters, it deals 2 damage to any target. You gain 1 life.").class_source("EntersTrigger")
    expect(source).to include("class TargetChoice < Magic::Choice::Targeted", "game.any_target",
                              "def resolve!(target:)\n      trigger_effect(:deal_damage, target: target, damage: 2)\n      trigger_effect(:gain_life",
                              "def call\n    choice = TargetChoice.new(actor: actor)\n    game.add_choice(choice) if choice.choices.any?")
  end

  it "nests a target choice inside a scry choice, doing nothing without a target" do
    source = parse("When ~ enters, scry 1. Destroy target creature.").class_source("EntersTrigger")
    expect(source).to include("class ScryChoice < Magic::Choice::Scry\n    class TargetChoice < Magic::Choice::Targeted",
                              "def call\n    return if battlefield.creatures.none?\n    game.choices.add(ScryChoice.new(actor: actor, amount: 1))")
  end

  it "runs the effects after an optional one whether or not it is accepted" do
    source = parse("When ~ dies, you may draw a card. If you do, discard a card. You gain 1 life.").class_source("DiesTrigger")
    expect(source).to include("trigger_effect(:draw_cards, number_to_draw: 1)\n      game.add_choice(Magic::Choice::Discard.new(player: controller))\n      finish",
                              "def decline! = finish", "def finish\n      trigger_effect(:gain_life")
  end

  it "rejects effects after an optional effect that makes its own choice" do
    expect { parse("When ~ enters, you may scry 1. Draw a card.").class_source("X") }.to raise_error(Magic::CardParser::UnsupportedCard)
  end
end
