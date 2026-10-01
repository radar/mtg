# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated Mobilize and Flurry cards in play" do
  include CardParserHelpers
  include_context "two player game"

  def warriors = p1.creatures.select { _1.name == "Warrior" }

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
  end

  context "Mobilize 2" do
    let!(:leader) do
      load_card("Parsed Mobilizer {1}{R}\nCreature — Goblin Warrior\nMobilize 2 (Whenever this creature attacks, create two tapped and attacking 1/1 red Warrior creature tokens. Sacrifice them at the beginning of the next end step.)\n2/2\n")
      ResolvePermanent("Parsed Mobilizer", owner: p1)
    end

    it "creates tapped and attacking Warriors that hit the defending player" do
      attack_with(leader)

      expect(warriors.size).to eq(2)
      expect(warriors).to all(be_tapped)
      expect(current_turn.attacks.map(&:attacker)).to include(*warriors)
      expect(current_turn.attacks.map(&:target).uniq).to eq([p2])
      expect(warriors.map { [_1.power, _1.toughness, _1.colors] }.uniq).to eq([[1, 1, [:red]]])

      expect { go_to_combat_damage! }.to change { p2.life }.by(-4)
    end

    it "does nothing when it doesn't attack" do
      expect(warriors).to be_empty
    end

    it "sacrifices the Warriors at the beginning of the next end step" do
      attack_with(leader)
      go_to_combat_damage!
      current_turn.end!
      game.settle!

      expect(warriors).to be_empty
      expect(p1.creatures).to eq([leader])
    end
  end

  context "Mobilize X" do
    it "counts the creature cards in your graveyard as it attacks" do
      load_card("Parsed Avenger {2}{B}\nCreature — Human Warrior\nMobilize X, where X is the number of creature cards in your graveyard. (Whenever this creature attacks, create X tapped and attacking 1/1 red Warrior creature tokens. Sacrifice them at the beginning of the next end step.)\n2/4\n")
      avenger = ResolvePermanent("Parsed Avenger", owner: p1)
      3.times { p1.graveyard.add(Card("Grizzly Bears")) }
      attack_with(avenger)

      expect(warriors.size).to eq(3)
    end
  end

  context "Flurry" do
    let!(:monk) do
      load_card("Parsed Monk {1}{R}\nCreature — Human Monk\nFlurry — Whenever you cast your second spell each turn, ~ deals 1 damage to each opponent.\n2/2\n")
      ResolvePermanent("Parsed Monk", owner: p1)
    end

    before do
      go_to_main_phase!
      p1.add_mana(red: 4)
    end

    def cast_bolt
      card = Card("Lightning Bolt")
      p1.hand.add(card)
      p1.cast(card:) { |action| action.pay_mana(red: 1) ; action.targeting(p2) }
      game.stack.resolve!
      game.settle!
    end

    it "triggers on the second spell cast in a turn only" do
      cast_bolt
      expect(p2.life).to eq(17)
      cast_bolt
      expect(p2.life).to eq(13) # 3 from the bolt, plus 1 from flurry
      cast_bolt
      expect(p2.life).to eq(10)
    end

    it "starts counting again on the next turn" do
      cast_bolt
      game.next_turn
      game.next_turn
      go_to_main_phase!
      p1.add_mana(red: 2)
      cast_bolt
      expect(p2.life).to eq(14)
    end
  end
end
