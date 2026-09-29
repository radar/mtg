# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KirolAttentiveFirstYear do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:kirol) { ResolvePermanent("Kirol, Attentive First-Year", owner: p1) }
  let!(:helper) { ResolvePermanent("Grizzly Bears", owner: p1) }

  # Put a Vibrance-style life-drain trigger on the stack without resolving it: gain life via Shimmercreep-like
  # trigger source. Bitterbloom Bearer's upkeep trigger (lose 1, make a Faerie) is easy to observe.
  def stack_upkeep_trigger
    ResolvePermanent("Bitterbloom Bearer", owner: p1)
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
    game.check_state_based_actions!
    game.stack.abilities.find { _1.is_a?(Magic::Cards::BitterbloomBearer::UpkeepTrigger) }
  end

  def copy(trigger)
    p1.activate_ability(ability: kirol.activated_abilities.first) { _1.pay_multi_tap([kirol, helper]).targeting(trigger) }
  end

  it "is a 3/3 legendary Vampire Cleric" do
    expect([kirol.power, kirol.toughness]).to eq([3, 3])
    expect(kirol).to be_legendary
  end

  it "copies a triggered ability you control, so its effect happens twice" do
    trigger = stack_upkeep_trigger
    life = p1.life
    copy(trigger)
    game.stack.resolve!
    game.settle!

    expect(p1.life).to eq(life - 2)
    expect(p1.creatures.count { _1.name == "Faerie" }).to eq(2)
  end

  it "taps two untapped creatures you control" do
    trigger = stack_upkeep_trigger
    copy(trigger)

    expect([kirol, helper]).to all(be_tapped)
  end

  it "can only be activated once each turn" do
    trigger = stack_upkeep_trigger
    copy(trigger)
    kirol.untap!
    helper.untap!

    expect { copy(trigger) }.to raise_error(Magic::IllegalAction)
  end

  it "only targets triggered abilities you control" do
    stack_upkeep_trigger

    expect(kirol.activated_abilities.first.target_choices).to all(be_a(Magic::TriggeredAbility))
    expect(kirol.activated_abilities.first.target_choices.map(&:controller)).to all(eq(p1))
  end

  it "needs two untapped creatures" do
    ability = kirol.activated_abilities.first
    helper.tap!

    expect(ability.costs.first.can_pay?(p1)).to be(false)
  end
end
