# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IdolOfFalseGods do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:idol) { ResolvePermanent("Idol Of False Gods", owner: p1) }

  def spawns(player = p1) = player.creatures.select { _1.name == "Eldrazi Spawn" }

  def plus_counters = idol.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a Kindred Artifact Eldrazi that is not a creature" do
    expect(idol).to be_type("Eldrazi")
    expect(idol).to be_type(Magic::Types::Artifact)
    expect(idol).not_to be_creature
  end

  describe "{1}{C}, {T}: create an Eldrazi Spawn" do
    it "creates a 0/1 Eldrazi Spawn token and taps the Idol" do
      p1.add_mana(red: 1, colorless: 1)
      p1.activate_ability(ability: idol.activated_abilities.first) { |a| a.pay_mana(generic: { red: 1 }, colorless: 1) }
      game.stack.resolve!
      game.settle!

      expect(spawns.size).to eq(1)
      expect([spawns.first.power, spawns.first.toughness]).to eq([0, 1])
      expect(idol).to be_tapped
    end

    it "cannot be paid without colorless mana" do
      p1.add_mana(red: 2)
      expect do
        p1.activate_ability(ability: idol.activated_abilities.first) { |a| a.pay_mana(generic: { red: 1 }, colorless: 1) }
      end.to raise_error(StandardError)
      expect(spawns).to be_empty
    end
  end

  describe "whenever another Eldrazi you control dies" do
    before { idol.create_eldrazi_spawn; game.settle! }

    it "puts a +1/+1 counter on the Idol" do
      spawns.first.destroy!
      game.settle!

      expect(plus_counters).to eq(1)
    end

    it "counts a non-creature Eldrazi (a second Idol) dying" do
      other = ResolvePermanent("Idol Of False Gods", owner: p1)
      other.destroy!
      game.settle!

      expect(plus_counters).to eq(1)
    end

    it "does not trigger when another Eldrazi is bounced instead of dying" do
      other = ResolvePermanent("Idol Of False Gods", owner: p1)
      other.return_to_hand
      game.settle!

      expect(plus_counters).to eq(0)
    end

    it "does not trigger when another Eldrazi is exiled instead of dying" do
      other = ResolvePermanent("Idol Of False Gods", owner: p1)
      other.exile!
      game.settle!

      expect(plus_counters).to eq(0)
    end

    it "does not trigger for itself dying (it is not 'another' Eldrazi)" do
      idol.add_counter(Magic::Counters::Plus1Plus1, amount: 2)
      idol.destroy!
      game.settle!

      expect(p1.graveyard.cards.map(&:name)).to include("Idol Of False Gods")
      expect(game.stack.abilities).to be_empty
      expect(plus_counters).to eq(2)
    end

    it "does not trigger for an opponent's Eldrazi" do
      idol.create_eldrazi_spawn(controller: p2)
      game.settle!
      spawns(p2).first.destroy!
      game.settle!

      expect(plus_counters).to eq(0)
    end

    it "does not trigger for a non-Eldrazi creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.destroy!
      game.settle!

      expect(plus_counters).to eq(0)
    end
  end

  describe "eight or more +1/+1 counters" do
    it "is not a creature with seven counters" do
      idol.add_counter(Magic::Counters::Plus1Plus1, amount: 7)
      game.tick!

      expect(idol).not_to be_creature
    end

    context "with eight counters" do
      before do
        idol.add_counter(Magic::Counters::Plus1Plus1, amount: 8)
        game.tick!
      end

      it "is an Artifact Eldrazi creature in addition to its other types, 8/8 from the counters" do
        expect(idol).to be_creature
        expect(idol).to be_type(Magic::Types::Artifact)
        expect(idol).to be_type("Eldrazi")
        expect([idol.power, idol.toughness]).to eq([8, 8])
      end

      it "has annihilator 2" do
        expect(idol.keywords.grep(Magic::Cards::Keywords::Annihilator).map(&:amount)).to eq([2])
      end

      it "makes the defending player sacrifice two permanents when it attacks" do
        ResolvePermanent("Grizzly Bears", owner: p2)
        ResolvePermanent("Serra Angel", owner: p2)
        ResolvePermanent("Island", owner: p2)
        idol.controlled_since_turn = 0
        skip_to_combat!
        current_turn.declare_attackers!
        p1.declare_attacker(attacker: idol, target: p2)
        current_turn.attackers_declared!
        game.settle!
        game.tick!

        expect(game.choices.size).to eq(1)
        chosen = p2.permanents.select { %w[Island Serra\ Angel].include?(_1.name) }
        game.resolve_choice!(sacrifices: chosen)
        game.settle!

        expect(p2.permanents.map(&:name)).to eq(["Grizzly Bears"])
      end

      it "stops being a creature when counters drop below eight" do
        idol.remove_counter(counter_type: Magic::Counters::Plus1Plus1)
        game.settle!
        game.tick!

        expect(idol).not_to be_creature
      end
    end
  end

  it "has no annihilator without eight counters" do
    expect(idol.keywords.grep(Magic::Cards::Keywords::Annihilator)).to be_empty
  end
end
