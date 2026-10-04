# frozen_string_literal: true

require "spec_helper"

RSpec.describe "graveyard triggers and combat requirements" do
  let(:parser) { Magic::CardParser }

  it "reads moving ~ out of the graveyard" do
    back = parser::Effect.parse("Return ~ from your graveyard to the battlefield.")
    expect(back).to be_a(parser::Effects::ReturnThisFromGraveyard)
    expect(back.works_from_graveyard?).to be(true)
    expect(back.resolve_call).to include(":return_target_from_graveyard_to_battlefield", "if #{parser::Effect::THIS}.zone&.graveyard?")
    top = parser::Effect.parse("Put ~ from your graveyard on top of your library.")
    expect(top.resolve_call).to include("move_zone!(to: #{parser::Effect::THIS}.owner.library)")
  end

  it "makes a trigger that moves its own card out of the graveyard a graveyard trigger" do
    rule = parser::Rules::Trigger.parse("At the beginning of combat on your turn, if you control a creature with power 4 or greater, you may pay {R}. If you do, return ~ from your graveyard to the battlefield.")
    source = rule.class_source("BeginningOfCombatTrigger")

    expect(source).to include("def self.works_from_graveyard? = true", "actor.zone&.graveyard?", "controller.creatures.any? { _1.power >= 4 }")
    plain = parser::Rules::Trigger.parse("At the beginning of combat on your turn, draw a card.")
    expect(plain.class_source("X")).not_to include("works_from_graveyard?")
  end

  it "reads 'a Gate you control enters'" do
    rule = parser::Rules::Trigger.parse("Whenever a Gate you control enters, you may put ~ from your graveyard on top of your library.")
    expect(rule.class_source("GateEntersTrigger")).to include('event.permanent.type?("Gate")', "works_from_graveyard?")
  end

  it "reads 'attacks each combat if able'" do
    expect(parser::Rules::MustAttack.parse("~ attacks each combat if able.").body_source).to eq("def must_attack? = true\n")
    expect(parser::Rules::MustAttack.parse("~ attacks each combat.")).to be_nil
  end

  it "reads 'you control a creature with power N or greater'" do
    expect(parser::Condition.parse("you control a creature with power 4 or greater")).to eq("controller.creatures.any? { _1.power >= 4 }")
  end

  it "reads 'Affinity for <Type>s' as a cost reduction" do
    rule = parser::Rules::SelfCostReduction.parse("Affinity for Gates")
    expect(rule.body_source).to include('controller.permanents.by_type("Gate").count')
    expect(parser::Rules::SelfCostReduction.parse("Affinity for artifacts").body_source).to include("controller.artifacts.count")
  end

  it "reads 'can't be blocked by creatures with power N or less'" do
    rule = parser::Rules::BlockingRestriction.parse("~ can't be blocked by creatures with power 2 or less.")
    expect(rule.body_source).to eq("def can_be_blocked?(blocker) = blocker.power > 2\n")
  end
end
