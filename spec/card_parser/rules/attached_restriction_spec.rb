# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::AttachedRestriction do
  it "turns each clause into a method on the Aura" do
    rule = described_class.parse("Enchanted creature can't become untapped and can't have counters put on it.")
    expect(rule.body_source).to eq("def prevents_untapping? = true\ndef prevents_counters? = true")
    expect(rule.kinds).to eq(%i[aura])
  end

  it "parses attacking, blocking, untapping and activated abilities" do
    expect(described_class.parse("Enchanted creature can't attack or block.").methods).to eq(["def can_attack? = false", "def can_block?(_) = false"])
    expect(described_class.parse("Enchanted creature doesn't untap during its controller's untap step.").methods)
      .to eq(["def does_not_untap_during_untap_step? = true"])
    expect(described_class.parse("Enchanted creature can't attack, and its activated abilities can't be activated.").methods)
      .to eq(["def can_attack? = false", "def can_activate_ability?(_) = false"])
    expect(described_class.parse("Equipped creature can't block.").kinds).to eq(%i[equipment])
  end

  it "ignores other clauses" do
    expect(described_class.parse("Enchanted creature can't be sacrificed.")).to be_nil
    expect(described_class.parse("Enchanted creature gets +1/+1.")).to be_nil
  end
end
