# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OmerOfTheRiddermark do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:omer) { ResolvePermanent("Omer Of The Riddermark", owner: p1) }

  def soldiers(player) = player.creatures.select { _1.token? && _1.type?("Soldier") }

  def declare_attack(creature, settle: true)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle! if settle
  end

  def queued_triggers = [*game.pending_triggers, *game.stack.abilities]

  def resolve_trigger
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary 5/4 Human Knight with haste" do
    expect([omer.power, omer.toughness]).to eq([5, 4])
    expect(omer).to be_legendary
    expect(omer.type?("Human")).to be(true)
    expect(omer.type?("Knight")).to be(true)
    expect(omer).to be_haste
  end

  it "creates a Human Soldier token when attacking while you control the creature with the greatest power" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    declare_attack(omer)
    resolve_trigger

    expect(soldiers(p1).count).to eq(1)
    expect(soldiers(p1).first.colors).to include(:white)
    expect(soldiers(p2)).to be_empty
  end

  it "still triggers when your creature is tied for the greatest power" do
    tied = ResolvePermanent("Grizzly Bears", owner: p2)
    tied.modify_power(3, until_eot: true)
    game.tick!
    expect(tied.power).to eq(5)
    declare_attack(omer)
    resolve_trigger

    expect(soldiers(p1).count).to eq(1)
  end

  it "does not trigger when an opponent controls a creature with greater power" do
    ResolvePermanent("Axegrinder Giant", owner: p2)
    declare_attack(omer, settle: false)

    expect(queued_triggers).to be_empty
    game.settle!
    expect(soldiers(p1)).to be_empty
    expect(game.choices).to be_empty
  end

  it "triggers when another creature you control has the greatest power, since Éomer need not be it" do
    omer.modify_power(-4, until_eot: true)
    giant = ResolvePermanent("Axegrinder Giant", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!
    expect(giant.power).to be > omer.power
    declare_attack(omer)
    resolve_trigger

    expect(soldiers(p1).count).to eq(1)
  end

  it "does nothing if a bigger creature appears before the trigger resolves" do
    event = Magic::Events::CreatureAttacked.new(attacker: omer, target: p2)
    trigger = described_class::AttackTrigger.new(event: event, actor: omer)
    expect(trigger.should_perform?).to be(true)

    ResolvePermanent("Axegrinder Giant", owner: p2)
    game.tick!
    trigger.call
    game.settle!

    expect(trigger.should_perform?).to be(false)
    expect(soldiers(p1)).to be_empty
  end

  it "does not trigger when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    declare_attack(bears, settle: false)

    expect(queued_triggers).to be_empty
    game.settle!
    expect(soldiers(p1)).to be_empty
  end
end
