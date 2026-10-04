# frozen_string_literal: true

require "spec_helper"

RSpec.describe "graveyard counts and conditions" do
  let(:parser) { Magic::CardParser }

  it "counts instant and sorcery cards in your graveyard" do
    expected = 'controller.graveyard.cards.by_any_type("Instant", "Sorcery").count'
    expect(parser::Count.parse("instant and sorcery cards in your graveyard")).to eq(expected)
    expect(parser::Count.parse("the number of instant and/or sorcery cards in your graveyard")).to eq(expected)
    expect(parser::Count.parse("creature card in your graveyard")).to eq("controller.graveyard.creatures.count")
  end

  it "reads 'N or more instant and/or sorcery cards in your graveyard'" do
    expect(parser::Condition.parse("there are two or more instant and/or sorcery cards in your graveyard"))
      .to eq('controller.graveyard.cards.by_any_type("Instant", "Sorcery").count >= 2')
    expect(parser::Condition.parse("there are seven or more cards in your graveyard")).to eq("controller.graveyard.cards.count >= 7")
  end

  it "reads 'you've gained N or more life this turn'" do
    expect(parser::Condition.parse("you've gained 3 or more life this turn")).to include("Events::LifeGain", ">= 3")
  end

  it "reads a leading 'As long as <condition>,' on a static buff" do
    rules = parser::Rules::StaticBuff.parse("As long as there are two or more instant and/or sorcery cards in your graveyard, ~ gets +1/+0 and has haste.")
    expect(rules.condition).to include("by_any_type")
    expect(rules.power).to eq(1)
    expect(rules.keywords).not_to be_empty
  end

  it "reads 'can't be blocked as long as <condition>'" do
    rule = parser::Rules::BlockingRestriction.parse("~ can't be blocked as long as there are seven or more cards in your graveyard.")
    expect(rule.body_source).to eq("def can_be_blocked?(_) = !(controller.graveyard.cards.count >= 7)\n")
    expect(parser::Rules::BlockingRestriction.parse("~ can't be blocked.").body_source).to eq("def can_be_blocked?(_) = false\n")
    expect(parser::Rules::BlockingRestriction.parse("~ can't be blocked as long as the moon is full.")).to be_nil
  end
end
