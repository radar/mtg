# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Soulherder do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:soulherder) { ResolvePermanent("Soulherder", owner: p1) }

  it "is a 1/1 Spirit" do
    expect(soulherder.power).to eq(1)
    expect(soulherder.toughness).to eq(1)
    expect(soulherder.type?("Spirit")).to be true
  end

  it "gets a +1/+1 counter when a creature you control is exiled from the battlefield" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    creature.exile!
    game.settle!

    expect(soulherder.counters.count).to eq(1)
  end

  it "gets a +1/+1 counter when an opponent's creature is exiled from the battlefield" do
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    creature.exile!
    game.settle!

    expect(soulherder.counters.count).to eq(1)
  end

  it "does not get a counter when a creature dies to the graveyard instead of being exiled" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    creature.destroy!

    expect(soulherder.counters).to be_empty
  end

  it "presents a may choice at the beginning of your end step when you control another creature" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    current_turn.end!

    expect(game.choices.last).to be_a(Magic::Cards::Soulherder::MayBlinkChoice)
  end

  it "does not present a choice at the beginning of your end step with no other creature you control" do
    current_turn.end!

    expect(game.choices).to be_empty
  end

  it "does not trigger at the beginning of an opponent's end step" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.next_turn

    current_turn.end!

    expect(game.choices).to be_empty
  end

  it "only offers creatures you control as blink targets" do
    ally = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)

    current_turn.end!
    game.resolve_choice!

    expect(game.choices.last.choices).to contain_exactly(ally)
  end

  it "does nothing when the may choice is declined" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)

    current_turn.end!
    game.skip_choice!

    expect(creature.zone).to be_battlefield
    expect(game.choices).to be_empty
  end

  it "exiles the target creature and returns it to the battlefield under its owner's control when accepted" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)
    card = creature.card

    current_turn.end!
    game.resolve_choice!
    game.resolve_choice!(target: creature)

    new_permanent = p1.permanents.by_name("Grizzly Bears").first

    expect(new_permanent).not_to eq(creature)
    expect(new_permanent.card).to eq(card)
    expect(new_permanent.zone).to be_battlefield
    expect(new_permanent.owner).to eq(p1)
  end

  it "gets a +1/+1 counter from its own blink ability exiling a creature" do
    creature = ResolvePermanent("Grizzly Bears", owner: p1)

    current_turn.end!
    game.resolve_choice!
    game.resolve_choice!(target: creature)
    game.settle!

    expect(soulherder.counters.count).to eq(1)
  end
end
