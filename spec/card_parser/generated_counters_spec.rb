# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

# Counters on other permanents (roadmap L1b): "each [other] [<Type>] creature [you control /
# an opponent controls]", "for each <count>", and "remove all <type> counters from ~".
RSpec.describe "CardParser generated counter effects in play" do
  include CardParserHelpers
  include_context "two player game"

  def end_step!
    go_to_main_phase!
    current_turn.end!
    game.settle!
  end

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  describe "Effects::AddCounters parsing" do
    let(:effect) { Magic::CardParser::Effect }

    it "reads each other creature you control, with an optional creature type" do
      expect(effect.parse("Put a +1/+1 counter on each other creature you control.").resolve_call)
        .to include("(battlefield.controlled_by(controller).creatures - [__this__]).each")
      expect(effect.parse("Put a +1/+1 counter on each other Dragon creature you control.").resolve_call)
        .to include('(battlefield.controlled_by(controller).creatures.by_any_type("Dragon") - [__this__]).each')
    end

    it "reads each creature, and each creature an opponent controls" do
      expect(effect.parse("Put a -1/-1 counter on each creature.").resolve_call).to include("battlefield.creatures.each")
      expect(effect.parse("Put a +1/+1 counter on each creature each opponent controls.").resolve_call)
        .to include("battlefield.not_controlled_by(controller).creatures.each")
    end

    it "scales the amount for each thing counted, and leaves an unknown count unparsed" do
      expect(effect.parse("Put a +1/+1 counter on ~ for each creature you control.").resolve_call)
        .to include("amount: 1 * controller.creatures.count")
      expect(effect.parse("Put a +1/+1 counter on ~ for each opponent who was dealt damage this turn.")).to be_nil
    end

    it "puts a named counter on any target permanent, but +1/+1 only on creatures" do
      expect(effect.parse("Put a charge counter on target artifact.").target_choices).to eq("battlefield.artifacts")
      expect(effect.parse("Put a charge counter on target permanent you control.").target_choices).to eq("battlefield.controlled_by(controller).permanents")
      expect(effect.parse("Put a +1/+1 counter on target artifact.")).to be_nil
    end

    it "reads several counter kinds in one sentence, keyword counters included" do
      call = effect.parse("Put a flying counter, a deathtouch counter, and a lifelink counter on target creature.").resolve_call
      expect(call.scan("trigger_effect(:add_counter").size).to eq(3)
      expect(call).to include('counter_type: "deathtouch"')
      expect(effect.parse("Put two +1/+1 counters and a reach counter on target creature.").resolve_call).to include("amount: 2", 'counter_type: "reach"')
    end

    it "reads doubling counters" do
      expect(effect.parse("Double the number of +1/+1 counters on ~.").resolve_call).to include("amount: __this__.counters.of_type(Counters[\"+1/+1\"]).count")
      expect(effect.parse("Double the number of +1/+1 counters on each creature you control.").resolve_call)
        .to include("battlefield.controlled_by(controller).creatures.each")
      expect(effect.parse("Double the number of frobnicate counters on enchanted creature.").resolve_call).to include("__this__.attached_to")
    end

    it "reads remove all counters" do
      expect(effect.parse("Remove all charge counters from ~.").resolve_call)
        .to eq("trigger_effect(:remove_counter, counter_type: Counters::Charge, target: __this__, amount: __this__.counters.of_type(Counters::Charge).count) " \
               "if __this__.counters.of_type(Counters::Charge).any?")
    end
  end

  it "puts a counter on each other creature you control, not the source, not the opponent's" do
    load_card("Parsed Captain {2}{W}\nCreature — Human\nAt the beginning of your end step, put a +1/+1 counter on each other creature you control.\n2/2\n")
    captain = ResolvePermanent("Parsed Captain", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    rival = ResolvePermanent("Grizzly Bears", owner: p2)
    end_step!
    expect([counters(captain), counters(bears), counters(rival)]).to eq([0, 1, 0])
  end

  it "puts a counter on each creature of a type" do
    load_card("Parsed Roost {2}{R}\nEnchantment\nAt the beginning of your end step, put a +1/+1 counter on each Goblin creature you control.\n")
    ResolvePermanent("Parsed Roost", owner: p1)
    goblin = ResolvePermanent("Mogg Fanatic", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    end_step!
    expect([counters(goblin), counters(bears)]).to eq([1, 0])
  end

  it "puts a -1/-1 counter on each creature, killing X/1s" do
    load_card("Parsed Blight {1}{B}\nEnchantment\nAt the beginning of your end step, put a -1/-1 counter on each creature.\n")
    ResolvePermanent("Parsed Blight", owner: p1)
    fanatic = ResolvePermanent("Mogg Fanatic", owner: p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    end_step!
    expect(fanatic.zone).to be_nil
    expect(bears.power).to eq(1)
  end

  it "scales the counters by the creatures you control" do
    load_card("Parsed Swarm {3}{G}\nCreature — Insect\nAt the beginning of your end step, put a +1/+1 counter on ~ for each creature you control.\n1/1\n")
    swarm = ResolvePermanent("Parsed Swarm", owner: p1)
    2.times { ResolvePermanent("Grizzly Bears", owner: p1) }
    end_step!
    expect(counters(swarm)).to eq(3)
  end

  it "doubles the +1/+1 counters on itself and on each creature you control" do
    load_card("Parsed Growth {3}{G}\nCreature — Elf\nAt the beginning of your end step, double the number of +1/+1 counters on ~.\n" \
              "At the beginning of your end step, double the number of +1/+1 counters on each other creature you control.\n1/1\n")
    growth = ResolvePermanent("Parsed Growth", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    growth.add_counter("+1/+1", amount: 2)
    bears.add_counter("+1/+1", amount: 3)
    end_step!
    expect([counters(growth), counters(bears)]).to eq([4, 6])
  end

  it "puts a named counter on a target artifact" do
    load_card("Parsed Charger {2}\nArtifact\nAt the beginning of your end step, put a charge counter on target artifact you control.\n")
    artifact = ResolvePermanent("Parsed Charger", owner: p1)
    end_step!
    expect(artifact.counters.of_type(Magic::Counters::Charge).count).to eq(1)
  end

  it "removes all counters of a type" do
    load_card("Parsed Battery {2}\nArtifact\nAt the beginning of your end step, remove all charge counters from ~.\n")
    battery = ResolvePermanent("Parsed Battery", owner: p1)
    battery.add_counter("charge", amount: 3)
    end_step!
    expect(battery.counters.of_type(Magic::Counters::Charge).count).to eq(0)
  end
end
