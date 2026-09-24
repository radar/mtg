# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::CardParser::Rules::StaticBuff do
  it "parses buffs, keywords, or both, for creatures you control" do
    expect(described_class.parse("Creatures you control get +1/+1.")).to eq(described_class.new("creatures you control", 1, 1, nil, []))
    expect(described_class.parse("Other creatures you control get +1/+0 and have vigilance."))
      .to eq(described_class.new("other creatures you control", 1, 0, nil, [:vigilance]))
    expect(described_class.parse("Creatures you control have flying and haste.")).to eq(described_class.new("creatures you control", nil, nil, nil, %i[flying haste]))
  end

  it "parses buffs for the equipped or enchanted creature" do
    expect(described_class.parse("Equipped creature gets +2/+0.")).to eq(described_class.new("equipped creature", 2, 0, nil, []))
    expect(described_class.parse("Enchanted creature gets +1/+1 and has flying.")).to eq(described_class.new("enchanted creature", 1, 1, nil, [:flying]))
    expect(described_class.parse("Equipped creature has hexproof and haste.")).to eq(described_class.new("equipped creature", nil, nil, nil, %i[hexproof haste]))
  end

  it "limits each subject to the cards it makes sense on" do
    expect(described_class.parse("Equipped creature gets +2/+0.").kinds).to eq(%i[equipment])
    expect(described_class.parse("Enchanted creature gets +2/+0.").kinds).to eq(%i[aura])
    expect(described_class.parse("Creatures you control get +1/+1.").kinds).to include(:enchantment, :creature)
  end

  it "parses a buff that counts something, for any subject" do
    blade = described_class.parse("Equipped creature gets +1/+1 for each Equipment you control.")
    expect([blade.power, blade.toughness, blade.per]).to eq([1, 1, "controller.equipment.count"])
    expect(described_class.parse("~ gets +1/+1 for each other Elf you control.").subject).to eq("~")
    expect(described_class.parse("~ gets +1/+1 for each other Elf you control.").kinds).to eq(%i[creature])
    expect(described_class.parse("Equipped creature gets +1/+1 for each opponent you have.")).to be_nil
  end

  it "renders a counted buff as methods, leaving out a zero change" do
    rule = described_class.parse("Enchanted creature gets +2/+0 for each card in your hand.")
    expect(rule.class_source("EnchantedCreatureBuff")).to eq(<<~RUBY)
      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        applies_to_target

        def power_modification = 2 * controller.hand.count
      end
    RUBY
  end

  it "ignores other lines" do
    expect(described_class.parse("Creatures you control get +1/+1 until end of turn.")).to be_nil
    expect(described_class.parse("Creatures you control have ward 2.")).to be_nil
    expect(described_class.parse("Other Elves you control get +1/+1.")).to be_nil
  end

  it "splits a buff with keywords into two static abilities" do
    rules = described_class.merge([described_class.parse("Other creatures you control get +1/+1 and have trample.")])
    expect(rules.map(&:class_base_name)).to eq(%w[CreaturesYouControlBuff CreaturesYouControlKeywords])
    expect(rules.first.class_source("CreaturesYouControlBuff")).to eq(<<~RUBY)
      class CreaturesYouControlBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applicable_targets { source.controller.creatures - [source] }
      end
    RUBY
    expect(rules.last.class_source("CreaturesYouControlKeywords")).to include("keyword_grants Keywords::TRAMPLE")
  end

  it "applies attached buffs to the attached creature" do
    rules = described_class.merge([described_class.parse("Equipped creature gets +1/+1 and has first strike.")])
    expect(rules.map(&:class_base_name)).to eq(%w[EquippedCreatureBuff EquippedCreatureKeywords])
    expect(rules.map { _1.class_source(_1.class_base_name) }).to all(include("applies_to_target"))
  end
end
