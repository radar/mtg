# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GuideOfSouls do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:guide) { ResolvePermanent("Guide of Souls", owner: p1) }

  def attack_with(*creatures)
    skip_to_combat!
    current_turn.declare_attackers!
    creatures.each { |c| current_turn.declare_attacker(c, target: p2) }
    current_turn.attackers_declared!
    game.tick!
  end

  it "is a 1/2 Human Cleric" do
    expect([guide.power, guide.toughness]).to eq([1, 2])
    expect(guide.type?("Cleric")).to be(true)
  end

  it "gains 1 life and 1 energy when another creature you control enters" do
    expect { ResolvePermanent("Grizzly Bears", owner: p1); game.settle! }
      .to change { p1.life }.by(1).and change { p1.energy }.by(1)
  end

  it "does not trigger for an opponent's creature" do
    expect { ResolvePermanent("Grizzly Bears", owner: p2); game.settle! }
      .not_to change { [p1.life, p1.energy] }
  end

  it "does not trigger for itself entering" do
    expect(p1.energy).to eq(0)
    expect(p1.life).to eq(20)
  end

  context "when attacking" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      game.settle!
    end

    it "pays three energy for two +1/+1 counters, a flying counter and the Angel type" do
      2.times { ResolvePermanent("Grizzly Bears", owner: p1) }
      game.settle!
      expect(p1.energy).to eq(3)
      attack_with(bears, guide)
      game.resolve_choice!
      expect(game.choices.to_a.map(&:class)).to eq([described_class::AttackTrigger::CountersChoice])
      game.resolve_choice!(target: bears)
      game.settle!

      expect(p1.energy).to eq(0)
      expect(guide.power).to eq(1)
      expect([bears.power, bears.toughness]).to eq([4, 4])
      expect(bears).to be_flying
      expect(bears.type?("Angel")).to be(true)
      expect(bears.type?("Bear")).to be(true)
    end

    it "offers no choice with fewer than three energy" do
      attack_with(bears)
      expect(p1.energy).to eq(1)
      expect(game.choices).to be_empty
    end

    it "does nothing when declined" do
      2.times { ResolvePermanent("Grizzly Bears", owner: p1) }
      game.settle!
      e = p1.energy
      attack_with(bears)
      game.skip_choice!
      game.settle!
      expect(p1.energy).to eq(e)
      expect(bears.power).to eq(2)
      expect(bears.type?("Angel")).to be(false)
    end
  end
end
