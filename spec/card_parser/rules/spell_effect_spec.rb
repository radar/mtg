# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::SpellEffect do
  let(:e) { Magic::CardParser::Effects }

  def spell(*lines)
    described_class.merge(lines.map { described_class.parse(_1) }).first
  end

  it "merges effect lines in order" do
    expect(spell("Scry 1.", "Draw a card.").effects).to eq([e.const_get(:Scry).new(1), e.const_get(:DrawCards).new(1)])
  end

  it "resolves untargeted effects in order" do
    source = spell("Draw two cards.", "You gain 2 life.").body_source
    expect(source).to eq(<<~RUBY)
      def resolve!
        trigger_effect(:draw_cards, number_to_draw: 2)
        trigger_effect(:gain_life, target: controller, life: 2)
      end
    RUBY
  end

  it "runs the effects after a scry once the scry choice resolves" do
    source = spell("Scry 1.", "Draw a card.").body_source
    expect(source).to include("class ScryChoice < Magic::Choice::Scry", "super(**args)\n    trigger_effect(:draw_cards, number_to_draw: 1)",
                              "def resolve!\n  game.choices.add(ScryChoice.new(actor: self, amount: 1))\nend")
  end

  it "keeps a targeted effect before a scry in resolve!" do
    source = spell("~ deals 2 damage to any target.", "Scry 1.").body_source
    expect(source).to include("game.any_target", "def resolve!(target:)\n  trigger_effect(:deal_damage, target: target, damage: 2)\n  game.choices.add")
  end

  it "rejects combinations it cannot generate" do
    expect { spell("Destroy target creature.", "Destroy target artifact.").body_source }.to raise_error(Magic::CardParser::UnsupportedCard)
    expect { spell("Scry 1.", "Destroy target creature.").body_source }.to raise_error(Magic::CardParser::UnsupportedCard)
    expect { spell("Scry 1.", "Scry 2.").body_source }.to raise_error(Magic::CardParser::UnsupportedCard)
    expect { spell("You may draw a card.").body_source }.to raise_error(Magic::CardParser::UnsupportedCard, /you may/)
  end
end
