# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Effects::Endure do
  it "parses ~, it and that creature as the subject" do
    expect(described_class.parse("~ endures 2.")).to eq(described_class.new(amount: 2, subject: "~"))
    expect(described_class.parse("It endures 1.")).to eq(described_class.new(amount: 1, subject: "it"))
    expect(described_class.parse("That creature endures one")).to eq(described_class.new(amount: 1, subject: "that creature"))
  end

  it "takes X inside with_x" do
    effect = Magic::CardParser::Number.with_x("actor.counters.count") { described_class.parse("it endures X") }
    expect(effect.amount).to eq("actor.counters.count")
  end

  it "is a Choice::Endure, with the entering creature for \"that creature\"" do
    expect(described_class.parse("~ endures 3").choice_base).to eq("Magic::Choice::Endure")
    expect(described_class.parse("~ endures 3").choice_args).to eq(["amount: 3"])
    expect(described_class.parse("that creature endures 3").choice_args).to eq(["amount: 3", "creature: event.permanent"])
  end

  it "doesn't parse other sentences" do
    expect(described_class.parse("~ endures")).to be_nil
    expect(described_class.parse("Draw a card.")).to be_nil
  end
end

RSpec.describe Magic::CardParser::Effects::PayMana do
  it "parses \"pay {M}\" into a mana hash and a guard" do
    effect = described_class.parse("Pay {1}{W}.")
    expect(effect.mana).to eq({ generic: 1, white: 1 })
    expect(effect.choice_base).to eq("Magic::Choice::PayMana")
    expect(effect.choice_guard).to include(".can_pay?")
  end

  it "joins \"you may pay {M}. If you do, ...\" into the pay choice followed by the effect" do
    list = Magic::CardParser::EffectList.parse("You may pay {1}{W}. If you do, it endures 1.")
    expect(list.effects.map(&:class)).to eq([described_class, Magic::CardParser::Effects::Endure])
  end
end
