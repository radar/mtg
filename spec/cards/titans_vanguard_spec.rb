# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TitansVanguard do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:vanguard) { Card("Titans' Vanguard", owner: p1) }
  let!(:colorless) { ResolvePermanent("Basking Broodscale", owner: p1) }
  let!(:colored) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opponents) { ResolvePermanent("Basking Broodscale", owner: p2) }

  def cast_vanguard
    p1.add_mana(red: 4, green: 1)
    p1.cast(card: vanguard) { _1.pay_mana(generic: { red: 3 }, red: 1, green: 1) }
  end

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a devoid 5/5 trampler" do
    expect(vanguard.colors).to be_empty
    expect(vanguard.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to be(true)
    expect(ResolvePermanent("Titans' Vanguard", owner: p1).power).to eq(5)
  end

  it "puts a counter on each colorless creature you control when cast, and nothing else" do
    cast_vanguard
    game.stack.resolve!
    game.settle!

    expect(counters(colorless)).to eq(1)
    expect(counters(colored)).to eq(0)
    expect(counters(opponents)).to eq(0)
  end

  context "once it is on the battlefield" do
    let!(:vanguard_permanent) { ResolvePermanent("Titans' Vanguard", owner: p1) }

    def attack_with(creature)
      skip_to_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: creature, target: p2)
      current_turn.attackers_declared!
      game.settle!
    end

    it "puts a counter on each colorless creature you control, itself included, when it attacks" do
      attack_with(vanguard_permanent)

      expect(counters(vanguard_permanent)).to eq(1)
      expect(counters(colorless)).to eq(1)
      expect(counters(colored)).to eq(0)
      expect(counters(opponents)).to eq(0)
    end

    it "does not trigger when another creature attacks" do
      attack_with(colorless)

      expect(counters(vanguard_permanent)).to eq(0)
      expect(counters(colorless)).to eq(0)
    end

    it "does not trigger when it enters without being cast" do
      expect(counters(vanguard_permanent)).to eq(0)
      expect(counters(colorless)).to eq(0)
    end
  end
end
