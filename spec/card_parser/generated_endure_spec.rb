# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated endure in play" do
  include CardParserHelpers
  include_context "two player game"

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count
  def spirits(player) = player.permanents.select { _1.name == "Spirit" }.to_a

  def spirit(player)
    expect(spirits(player).size).to eq(1)
    spirits(player).first
  end

  describe "\"When ~ enters, it endures 2.\"" do
    before { load_card("Parsed Endurer {3}{G}\nCreature — Human\nWhen ~ enters, it endures 2.\n2/2\n") }

    it "puts two +1/+1 counters on it when accepted" do
      endurer = ResolvePermanent("Parsed Endurer", owner: p1)
      expect(game.choices.last).to be_a(Magic::Choice::Endure)
      game.resolve_choice!
      expect(plus_counters(endurer)).to eq(2)
      expect(spirits(p1)).to be_empty
    end

    it "creates a 2/2 white Spirit token when declined" do
      endurer = ResolvePermanent("Parsed Endurer", owner: p1)
      game.skip_choice!
      expect(plus_counters(endurer)).to eq(0)
      token = spirit(p1)
      expect([token.power, token.toughness]).to eq([2, 2])
      expect(token.colors).to eq([:white])
      expect(token.type?("Spirit")).to be(true)
    end

    it "creates the token even when accepted if the creature has left the battlefield" do
      endurer = ResolvePermanent("Parsed Endurer", owner: p1)
      endurer.destroy!
      game.resolve_choice!
      expect(spirit(p1).power).to eq(2)
    end
  end

  describe "\"Whenever ~ attacks, you lose 1 life and ~ endures 1.\"" do
    it "loses life, then asks" do
      load_card("Parsed Surveyor {1}{B}\nCreature — Bird\nWhenever ~ attacks, you lose 1 life and this creature endures 1.\n1/3\n")
      surveyor = ResolvePermanent("Parsed Surveyor", owner: p1)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: surveyor, target: p2)
      current_turn.attackers_declared!
      game.resolve_choice!
      expect(p1.life).to eq(19)
      expect(plus_counters(surveyor)).to eq(1)
    end
  end

  describe "\"you may pay {1}{W}. If you do, it endures 1.\"" do
    before do
      load_card("Parsed Descendant {W}\nCreature — Human\nWhenever ~ attacks, you may pay {1}{W}. If you do, it endures 1.\n2/1\n")
    end

    let!(:descendant) { ResolvePermanent("Parsed Descendant", owner: p1) }

    def attack!
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: descendant, target: p2)
      current_turn.attackers_declared!
    end

    it "pays and then endures when it can" do
      p1.add_mana(white: 2)
      attack!
      game.resolve_choice!
      game.resolve_choice!
      expect(plus_counters(descendant)).to eq(1)
    end

    it "does nothing when declined" do
      p1.add_mana(white: 2)
      attack!
      game.skip_choice!
      expect(game.choices).to be_empty
      expect(plus_counters(descendant)).to eq(0)
    end

    it "does nothing when the mana can't be paid" do
      attack!
      expect(game.choices).to be_empty
      expect(plus_counters(descendant)).to eq(0)
    end
  end

  describe "\"Whenever another nontoken creature you control dies, ~ endures 2.\"" do
    before do
      load_card("Parsed Anafenza, Unyielding {2}{W}\nLegendary Creature — Spirit Soldier\nWhenever another nontoken creature you control dies, Parsed Anafenza endures 2.\n2/2\n")
    end

    let!(:anafenza) { ResolvePermanent("Parsed Anafenza, Unyielding", owner: p1) }

    it "endures when a nontoken creature of yours dies" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.destroy!
      game.settle!
      game.resolve_choice!
      expect(plus_counters(anafenza)).to eq(2)
    end

    it "ignores an opponent's creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      bears.destroy!
      game.settle!
      expect(game.choices).to be_empty
    end
  end

  describe "\"Whenever another nontoken creature you control enters, it endures X, where X is the number of counters on ~.\"" do
    before do
      load_card("Parsed Warden {2}{G}\nCreature — Hydra\nWhenever another nontoken creature you control enters, it endures X, where X is the number of counters on this creature.\n2/2\n")
    end

    let!(:warden) { ResolvePermanent("Parsed Warden", owner: p1) }

    it "puts X counters on the creature that entered" do
      warden.add_counter("+1/+1", amount: 3)
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      game.resolve_choice!
      expect(plus_counters(bears)).to eq(3)
      expect(plus_counters(warden)).to eq(3)
    end

    it "makes an X/X Spirit when declined" do
      warden.add_counter("+1/+1", amount: 3)
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.skip_choice!
      expect(spirit(p1).power).to eq(3)
    end

    it "doesn't trigger for a token" do
      Magic::Choice::Endure::SpiritToken.new(game:, owner: p1).resolve!
      game.settle!
      expect(game.choices).to be_empty
    end
  end
end
