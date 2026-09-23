# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::Chapter do
  let(:draw) { Magic::CardParser::EffectList.new(effects: [Magic::CardParser::Effects::DrawCards.new(1)]) }

  it "parses a chapter and its effect" do
    expect(described_class.parse("II — Draw a card.")).to eq(described_class.new({ 2 => draw }))
  end

  it "parses a line shared by several chapters" do
    expect(described_class.parse("I, II — Draw a card.")).to eq(described_class.new({ 1 => draw, 2 => draw }))
  end

  it "ignores other lines" do
    expect(described_class.parse("Draw a card.")).to be_nil
  end

  it "rejects chapters with unsupported effects" do
    expect { described_class.parse("I — Mill two cards.") }.to raise_error(Magic::CardParser::UnsupportedCard, /Mill two cards/)
  end

  it "merges a card's chapters, requiring them in order" do
    lines = ["I — Draw a card.", "II, III — You gain 2 life."].map { described_class.parse(_1) }
    expect(described_class.merge(lines).map { _1.chapters.keys }).to eq([[1, 2, 3]])
    expect { described_class.merge([described_class.parse("II — Draw a card.")]) }.to raise_error(Magic::CardParser::ParseError, /without gaps/)
  end

  it "renders a choice effect's choice class inside the chapter" do
    source = described_class.parse("I — Scry 2, then draw a card.").body_source
    expect(source).to include("class ScryChoice < Magic::Choice::Scry", "trigger_effect(:draw_cards, number_to_draw: 1)",
                              "def resolve!\n    game.choices.add(ScryChoice.new(actor: actor, amount: 2))")
  end

  it "renders chapter abilities, a targeted one as a choice" do
    rule = described_class.merge(["I — Draw a card.", "II — ~ deals 2 damage to any target."].map { described_class.parse(_1) }).first
    source = rule.body_source
    expect(source).to include("class Chapter1 < Saga::ChapterAbility", "trigger_effect(:draw_cards, number_to_draw: 1)",
                              "class Chapter2 < Saga::ChapterAbility", "class TargetChoice < Magic::Choice::Targeted",
                              "game.any_target", "game.add_choice(choice) if choice.choices.any?", "[Chapter1, Chapter2]")
  end
end
