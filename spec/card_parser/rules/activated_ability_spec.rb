# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::ActivatedAbility do
  it "parses costs, turning ~ into {this}" do
    rule = described_class.parse("{1}, {T}, Sacrifice ~: Draw a card.")
    expect(rule.costs).to eq("{1}, {T}, Sacrifice {this}")
    expect(rule.effect_list.effects).to eq([Magic::CardParser::Effects::DrawCards.new(1)])
    expect(rule.sorcery_speed).to eq(false)
  end

  it "parses coloured mana, sacrificing a creature, and a sorcery-speed restriction" do
    rule = described_class.parse("{2}{B}, Sacrifice a creature: You gain 3 life. Activate only as a sorcery.")
    expect(rule.costs).to eq("{2}{B}, Sacrifice a creature")
    expect(rule.effect_list.effects).to eq([Magic::CardParser::Effects::GainLife.new(3)])
    expect(rule.sorcery_speed).to eq(true)
  end

  it "parses removing counters, with \"and sacrifice it\" as a second cost" do
    rule = described_class.parse("Remove three quest counters from ~ and sacrifice it: You gain 3 life.")
    expect(rule.costs).to eq("Remove 3 quest counters from {this}, Sacrifice {this}")
    expect(described_class.parse("{1}, Remove a +1/+1 counter from ~: Draw a card.").costs).to eq("{1}, Remove 1 +1/+1 counters from {this}")
  end

  it "ignores mana abilities, unknown costs and unknown effects" do
    expect(described_class.parse("{T}: Add {G}.")).to be_nil
    expect(described_class.parse("{X}{R}: ~ deals X damage to any target.")).to be_nil
    expect(described_class.parse("Remove a widget counter from ~: Draw a card.")).to be_nil
    expect(described_class.parse("Pay 2 life: Draw a card.")).to be_nil
    expect(described_class.parse("{1}: ~ gains protection from red until end of turn.")).to be_nil
  end

  it "renders a targeted ability like a spell" do
    source = described_class.parse("{T}: ~ deals 1 damage to any target.").class_source("ActivatedAbility")
    expect(source).to eq(<<~RUBY)
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          game.any_target
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 1)
        end
      end
    RUBY
  end

  it "renders a sorcery-speed requirement" do
    source = described_class.parse("{2}{U}: Scry 1, then draw a card. Activate only as a sorcery.").class_source("ActivatedAbility")
    expect(source).to include("def requirements_met? = game.can_cast_sorcery?(controller)", "class ScryChoice < Magic::Choice::Scry")
  end
end
