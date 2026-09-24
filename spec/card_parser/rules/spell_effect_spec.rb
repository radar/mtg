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

  it "acts on an earlier target for \"it\" and \"that creature\"" do
    source = spell("Target creature gets +2/+2 and gains first strike until end of turn. Untap it.").body_source
    expect(source).to include("def resolve!(target:)", "trigger_effect(:grant_keyword, target: target, keyword: :first_strike)\n  target.untap!")
    expect(spell("Tap target creature. That creature gains haste until end of turn.").body_source)
      .to include("trigger_effect(:grant_keyword, target: target, keyword: :haste)")
  end

  it "uses the latest earlier target for \"it\" in a spell with several targets" do
    source = spell("Tap target creature you control. Untap target creature an opponent controls. It gains haste until end of turn.").body_source
    expect(source).to include("trigger_effect(:tap, target: targets[0])", "targets[1].untap!",
                              "trigger_effect(:grant_keyword, target: targets[1], keyword: :haste)")
  end

  it "doesn't parse \"it\" with no earlier target" do
    expect(described_class.parse("Untap it.")).to be_nil
    expect(described_class.parse("Draw a card. It gains haste until end of turn.")).to be_nil
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
    expect { spell("Scry 1.", "Destroy target creature.").body_source }.to raise_error(Magic::CardParser::UnsupportedCard)
    expect { spell("Draw a card. You may destroy target creature.").body_source }.to raise_error(Magic::CardParser::UnsupportedCard)
  end

  it "gives a spell with several targets one list of choices per target" do
    source = spell("Destroy target creature.", "Destroy target artifact.").body_source
    expect(source).to eq(<<~RUBY)
      def multi_target? = true

      def target_choices
        [
          battlefield.creatures,
          battlefield.artifacts,
        ]
      end

      def resolve!(targets:)
        trigger_effect(:destroy_target, target: targets[0])
        trigger_effect(:destroy_target, target: targets[1])
      end
    RUBY
  end

  it "nests one choice inside another" do
    source = spell("Scry 1.", "Scry 2.").body_source
    expect(source).to include("class ScryChoice < Magic::Choice::Scry", "super(**args)\n    game.choices.add(Magic::Choice::Scry.new(actor: actor, amount: 2))",
                              "def resolve!\n  game.choices.add(ScryChoice.new(actor: self, amount: 1))")
  end

  it "asks with a MayChoice for an optional effect, running what follows either way" do
    source = spell("You may draw a card. If you do, you lose 1 life. You gain 2 life.").body_source
    expect(source).to eq(<<~RUBY)
      class MayChoice < Magic::Choice::May
        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
          trigger_effect(:lose_life, target: controller, life: 1)
          finish
        end

        def decline! = finish

        def finish
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def resolve!
        game.choices.add(MayChoice.new(actor: self))
      end
    RUBY
  end

  it "keeps effects before an optional one in resolve!" do
    source = spell("Draw a card, then you may discard a card.").body_source
    expect(source).to include("def resolve!\n  trigger_effect(:draw_cards, number_to_draw: 1)\n  game.choices.add(MayChoice.new(actor: self))")
  end
end

RSpec.describe Magic::CardParser::Rules::SpellEffect, "if this spell was kicked" do
  def spell(*lines)
    described_class.merge(lines.map { described_class.parse(_1) }).first
  end

  it "runs the kicked effects only when the kicker was paid" do
    source = spell("~ deals 2 damage to any target. If ~ was kicked, draw a card and you gain 2 life.").body_source
    expect(source).to eq(<<~RUBY)
      def target_choices
        game.any_target
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 2)
        if kicker_cost.paid?
          trigger_effect(:draw_cards, number_to_draw: 1)
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end
    RUBY
  end

  it "can end with a choice" do
    source = spell("Draw a card.", "If ~ was kicked, scry 2.").body_source
    expect(source).to include("if kicker_cost.paid?\n    game.choices.add(Magic::Choice::Scry.new(actor: self, amount: 2))\n  end")
  end

  it "rejects kicked effects it can't order or target" do
    expect { spell("If ~ was kicked, scry 2.", "Draw a card.").body_source }
      .to raise_error(Magic::CardParser::UnsupportedCard, /after a choice/)
    expect { spell("If ~ was kicked, destroy target creature.") }
      .to raise_error(Magic::CardParser::UnsupportedCard, /targeted/)
  end
end
