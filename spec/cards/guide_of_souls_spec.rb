# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GuideOfSouls do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) } # enters before the Guide, so it doesn't trigger
  let!(:guide) { ResolvePermanent("Guide Of Souls", owner: p1) }

  def attack(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
  end

  def counters(permanent, type) = permanent.counters.of_type(type).count

  it "is a 1/2 Human Cleric" do
    expect([guide.power, guide.toughness]).to eq([1, 2])
    expect(guide.type?("Human")).to be(true)
    expect(guide.type?("Cleric")).to be(true)
  end

  context "when another creature you control enters" do
    it "gains 1 life and gives an energy" do
      ResolvePermanent("Grizzly Bears", owner: p1)

      expect(p1.life).to eq(21)
      expect(p1.energy).to eq(1)
    end

    it "doesn't trigger for itself" do
      expect(p1.life).to eq(20)
      expect(p1.energy).to eq(0)
    end

    it "doesn't trigger for an opponent's creature" do
      ResolvePermanent("Grizzly Bears", owner: p2)

      expect(p1.life).to eq(20)
      expect(p1.energy).to eq(0)
    end

    it "doesn't trigger for a noncreature permanent" do
      ResolvePermanent("Ruby Medallion", owner: p1)

      expect(p1.life).to eq(20)
      expect(p1.energy).to eq(0)
    end
  end

  context "whenever you attack" do
    before { p1.add_counter("energy", amount: 3) }

    it "pays {E}{E}{E} to put two +1/+1 counters and a flying counter on an attacking creature, making it an Angel" do
      attack(bears)
      expect(game.choices.first).to be_a(Magic::Choice::PayEnergy)
      game.resolve_choice!
      game.settle!

      expect(p1.energy).to eq(0)
      expect(counters(bears, Magic::Counters::Plus1Plus1)).to eq(2)
      expect(counters(bears, Magic::Counters::Flying)).to eq(1)
      expect([bears.power, bears.toughness]).to eq([4, 4])
      expect(bears.type?("Angel")).to be(true)
      expect(bears.type?("Bear")).to be(true)
    end

    it "keeps the Angel type past end of turn" do
      attack(bears)
      game.resolve_choice!
      game.settle!
      current_turn.end!
      current_turn.cleanup!
      game.settle!

      expect(bears.type?("Angel")).to be(true)
      expect(counters(bears, Magic::Counters::Plus1Plus1)).to eq(2)
    end

    it "lets you choose among several attackers" do
      attack(bears, guide)
      game.resolve_choice!
      game.resolve_choice!(target: guide)
      game.settle!

      expect(counters(guide, Magic::Counters::Plus1Plus1)).to eq(2)
      expect(counters(bears, Magic::Counters::Plus1Plus1)).to eq(0)
    end

    it "does nothing when you decline" do
      attack(bears)
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(3)
      expect(counters(bears, Magic::Counters::Plus1Plus1)).to eq(0)
      expect(bears.type?("Angel")).to be(false)
    end

    it "offers nothing with fewer than three energy" do
      p1.pay_energy!(1)
      attack(bears)

      expect(game.choices).to be_empty
    end

    it "triggers once for several attackers" do
      attack(bears, guide)

      expect(game.choices.count { _1.is_a?(Magic::Choice::PayEnergy) }).to eq(1)
    end

    it "doesn't trigger when you don't attack" do
      skip_to_combat!
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
