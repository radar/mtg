# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated combat, end step and counter triggers in play" do
  include CardParserHelpers
  include_context "two player game"

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
  end

  context "with a generated raid captain" do
    let!(:captain) do
      load_card("Parsed Captain {2}{W}\nCreature — Human Soldier\n" \
                "Whenever Parsed Captain enters or attacks, create a 1/1 white Soldier creature token.\n" \
                "Whenever Parsed Captain deals combat damage to a player, draw a card.\n" \
                "At the beginning of combat on your turn, Parsed Captain gets +1/+0 until end of turn.\n2/2\n")
      ResolvePermanent("Parsed Captain", owner: p1)
    end

    def soldiers = p1.creatures.select { _1.name == "Soldier" }

    it "creates a token on entering and again on attacking" do
      expect(soldiers.size).to eq(1)
      attack_with(captain)
      expect(soldiers.size).to eq(2)
    end

    it "gets +1/+0 at the beginning of combat on your turn" do
      skip_to_combat!
      game.tick!
      expect(captain.power).to eq(3)
    end

    it "draws when it deals combat damage to a player" do
      attack_with(captain)
      expect { go_to_combat_damage! }.to change { p1.hand.count }.by(1)
      expect(p2.life).to eq(17)
    end
  end

  it "triggers on your attacks with any creature, not on the opponent's" do
    load_card("Parsed Drum {2}\nArtifact\nWhenever you attack, you gain 1 life.\n")
    ResolvePermanent("Parsed Drum", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)
    expect(p1.life).to eq(21)

    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker: theirs, target: p1)
    current_turn.attackers_declared!
    expect(p1.life).to eq(21)
  end

  it "triggers at every end step" do
    load_card("Parsed Hourglass {2}\nArtifact\nAt the beginning of each end step, you lose 1 life.\n")
    ResolvePermanent("Parsed Hourglass", owner: p1)
    go_to_main_phase!
    current_turn.end!
    game.next_turn
    go_to_main_phase!
    current_turn.end!
    expect(p1.life).to eq(18)
  end

  it "fades: enters with time counters, loses one each upkeep, and is sacrificed with the last" do
    load_card("Parsed Wisp {1}{U}\nCreature — Spirit\nParsed Wisp enters with two time counters on it.\n" \
              "At the beginning of your upkeep, remove a time counter from Parsed Wisp.\n" \
              "When the last time counter is removed from Parsed Wisp, sacrifice it.\n3/3\n")
    wisp = ResolvePermanent("Parsed Wisp", owner: p1)
    expect(wisp.counters.of_type(Magic::Counters::Time).count).to eq(2)

    2.times { game.next_turn }
    go_to_main_phase!
    expect(wisp.counters.of_type(Magic::Counters::Time).count).to eq(1)
    expect(wisp.zone).to be_battlefield

    2.times { game.next_turn }
    go_to_main_phase!
    expect(wisp.card.zone).to be_graveyard
  end
end
