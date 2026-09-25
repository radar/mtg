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
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      modes Mode1, Mode2
    RUBY
  end

  it "needs one header and two modes" do
    expect { modal("• Draw a card.", "• You gain 2 life.") }.to raise_error(Magic::CardParser::ParseError, /Choose/)
    expect { modal("Choose one —", "• Draw a card.") }.to raise_error(Magic::CardParser::ParseError, /two/)
  end
end
