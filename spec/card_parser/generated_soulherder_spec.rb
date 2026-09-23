# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

# Soulherder's current Oracle text, generated. Mirrors spec/cards/soulherder_spec.rb,
# except that a lone legal target is chosen automatically (game.add_choice).
RSpec.describe "CardParser generated Soulherder" do
  include CardParserHelpers
  include_context "two player game"

  let!(:herder_class) do
    load_card("Parsed Soulherder {1}{W}{U}\nCreature — Spirit\n" \
              "Whenever a creature is exiled from the battlefield, put a +1/+1 counter on this creature.\n" \
              "At the beginning of your end step, you may exile another target creature you control, " \
              "then return that card to the battlefield under its owner's control.\n1/1\n")
  end
  let!(:herder) { ResolvePermanent("Parsed Soulherder", owner: p1) }

  def counters = herder.counters.of_type(Magic::Counters::Plus1Plus1).count

  before { go_to_main_phase! }

  it "gets a counter when any creature is exiled from the battlefield, not when one dies" do
    ResolvePermanent("Grizzly Bears", owner: p1).exile!
    ResolvePermanent("Grizzly Bears", owner: p2).exile!
    ResolvePermanent("Grizzly Bears", owner: p1).destroy!
    expect(counters).to eq(2)
  end

  it "doesn't ask at your end step without another creature, nor at the opponent's" do
    current_turn.end!
    expect(game.choices).to be_empty

    ResolvePermanent("Grizzly Bears", owner: p1)
    game.next_turn
    current_turn.end!
    expect(game.choices).to be_empty
  end

  it "does nothing when declined" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    current_turn.end!
    expect(game.choices.last).to be_a(herder_class::EndStepTrigger::MayChoice)
    game.skip_choice!

    expect(bears.zone).to be_battlefield
    expect(game.choices).to be_empty
  end

  it "offers only your other creatures, then flickers the chosen one and gets a counter" do
    ally = ResolvePermanent("Grizzly Bears", owner: p1)
    other_ally = ResolvePermanent("Wood Elves", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    card = ally.card

    current_turn.end!
    game.resolve_choice!
    expect(game.choices.last.choices).to contain_exactly(ally, other_ally)
    game.resolve_choice!(target: ally)

    returned = p1.permanents.by_name("Grizzly Bears").first
    expect(returned).not_to eq(ally)
    expect([returned.card, returned.owner, returned.zone.battlefield?]).to eq([card, p1, true])
    expect(card.zone).to be_battlefield
    expect(p1.exile).to be_empty
    expect(counters).to eq(1)
  end

  it "flickers a lone other creature without asking which" do
    ally = ResolvePermanent("Grizzly Bears", owner: p1)
    current_turn.end!
    game.resolve_choice!

    expect(p1.permanents.by_name("Grizzly Bears").first).not_to eq(ally)
    expect(counters).to eq(1)
  end
end
