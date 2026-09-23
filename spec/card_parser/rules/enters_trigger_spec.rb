# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::EntersTrigger do
  let(:e) { Magic::CardParser::Effects }

  it "parses both enters wordings" do
    expect(described_class.parse("When ~ enters, draw a card.").effect_list.effects).to eq([e.const_get(:DrawCards).new(1)])
    expect(described_class.parse("When ~ enters the battlefield, you gain 3 life.").effect_list.effects).to eq([e.const_get(:GainLife).new(3)])
  end

  it "parses several effects" do
    effects = described_class.parse("When ~ enters, scry 2, then draw a card.").effect_list.effects
    expect(effects).to eq([e.const_get(:Scry).new(2), e.const_get(:DrawCards).new(1)])
  end

  it "ignores other lines and unknown effects" do
    expect(described_class.parse("When ~ dies, draw a card.")).to be_nil
    expect(described_class.parse("When ~ enters, return target card from your graveyard to your hand.")).to be_nil
  end

  it "renders an untargeted trigger" do
    source = described_class.parse("When ~ enters, draw a card.").class_source("EntersTrigger")
    expect(source).to eq(<<~RUBY)
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end
    RUBY
  end

  it "chooses targets with a choice, running later effects there too" do
    source = described_class.parse("When ~ enters, it deals 2 damage to any target. You gain 1 life.").class_source("EntersTrigger")
    expect(source).to include("class TargetChoice < Magic::Choice::Targeted", "game.any_target",
                              "def resolve!(target:)\n      trigger_effect(:deal_damage, target: target, damage: 2)\n      trigger_effect(:gain_life",
                              "def call\n    game.choices.add(TargetChoice.new(actor: actor))")
  end

  it "rejects a target and a scry in one trigger" do
    expect { described_class.parse("When ~ enters, scry 1. Destroy target creature.").class_source("X") }
      .to raise_error(Magic::CardParser::UnsupportedCard)
  end
end
