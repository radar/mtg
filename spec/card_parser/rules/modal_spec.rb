# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Modal do
  def modal(*lines) = described_class.merge(lines.map { described_class.parse(_1) })

  it "parses the header and bullets" do
    expect(described_class.parse("Choose one —").choose).to eq("one")
    expect(described_class.parse("Choose one or both —").choose).to eq("one or both")
    expect(described_class.parse("• Draw a card.").modes.first.effects).to eq([Magic::CardParser::Effects::DrawCards.new(1)])
    expect(described_class.parse("• Exile the top card of your library.")).to be_nil
  end

  it "renders a Mode class per bullet" do
    source = modal("Choose one —", "• ~ deals 2 damage to any target.", "• Draw a card.").first.body_source
    expect(source).to eq(<<~RUBY)
      class Mode1 < Mode
        def target_choices
          game.any_target
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 2)
        end
      end

      class Mode2 < Mode
        def resolve!
          trigger_effect(:draw_card)
        end
      end

      modes Mode1, Mode2
      choose_modes 1
    RUBY
  end

  it "parses a modal enters trigger and renders a ModeChoice for it" do
    rule = modal("When ~ enters, choose one —", "• Draw a card.", "• You gain 2 life.").first

    expect(rule.trigger).to be(true)
    expect([rule.hook, rule.class_base_name, rule.body_source]).to eq([:etb_triggers, "EntersTrigger", nil])
    expect(rule.class_source("EntersTrigger")).to include("MODES = [Mode1, Mode2].freeze", "class ModeChoice < Magic::Choice")
    expect(rule.kinds).to include(:creature)
  end

  it "only supports \"choose one\" for an enters trigger" do
    expect { modal("When ~ enters, choose two —", "• Draw a card.", "• You gain 2 life.") }
      .to raise_error(Magic::CardParser::UnsupportedCard)
  end

  it "turns each header into a mode count" do
    counts = ["one", "two", "one or both", "one or more"].map do |header|
      modal("Choose #{header} —", "• Draw a card.", "• You gain 2 life.").first.mode_count
    end

    expect(counts).to eq(["1", "2", "1..2", "1..2"])
  end

  it "needs one header and two modes" do
    expect { modal("• Draw a card.", "• You gain 2 life.") }.to raise_error(Magic::CardParser::ParseError, /Choose/)
    expect { modal("Choose one —", "• Draw a card.") }.to raise_error(Magic::CardParser::ParseError, /two/)
  end
end
