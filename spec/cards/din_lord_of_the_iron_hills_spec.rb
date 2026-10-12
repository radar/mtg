# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DinLordOfTheIronHills do
  include_context "two player game"

  let!(:lord) { ResolvePermanent("Dáin, Lord Of The Iron Hills", owner: p1) }

  def to_declare_attackers(player)
    go_to_main_phase_for!(player)
    skip_to_combat!
    current_turn.declare_attackers!
  end

  it "is a 2/2 vigilance legendary Dwarf Noble" do
    expect([lord.power, lord.toughness]).to eq([2, 2])
    expect(lord.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(true)
  end

  context "without an enduring story" do
    it "doesn't tax attackers" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      to_declare_attackers(p2)
      expect { p2.declare_attacker(attacker: bears, target: p1) }.not_to raise_error
    end
  end

  context "with an enduring story (three artifacts, legendaries and/or Sagas)" do
    before do
      ResolvePermanent("Short Sword", owner: p1)
      ResolvePermanent("Short Sword", owner: p1)
      game.tick!
    end

    it "stops a creature attacking you unless its controller pays {1}" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      to_declare_attackers(p2)
      expect { p2.declare_attacker(attacker: bears, target: p1) }.to raise_error(Magic::IllegalAction)
    end

    it "lets a creature attack you when {1} is paid" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      to_declare_attackers(p2)
      p2.add_mana(red: 1)
      p2.declare_attacker(attacker: bears, target: p1)
      expect(p2.mana_pool[:red]).to eq(0)
      expect(current_turn.attacking?(bears)).to eq(true)
    end

    it "keeps the story after the permanents leave" do
      # Magic::Storied records the story the first time a card asks (here: once, before the artifacts go).
      expect(Magic::Storied.enduring_story?(p1)).to eq(true)
      game.battlefield.controlled_by(p1).artifacts.each(&:destroy!)
      game.settle!
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      to_declare_attackers(p2)
      expect { p2.declare_attacker(attacker: bears, target: p1) }.to raise_error(Magic::IllegalAction)
    end

    it "charges {1} for each attacker" do
      first = ResolvePermanent("Grizzly Bears", owner: p2)
      second = ResolvePermanent("Grizzly Bears", owner: p2)
      to_declare_attackers(p2)
      p2.add_mana(red: 1)
      p2.declare_attacker(attacker: first, target: p1)
      expect { p2.declare_attacker(attacker: second, target: p1) }.to raise_error(Magic::IllegalAction)
    end

    it "doesn't tax attacks against the other player" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      to_declare_attackers(p1)
      expect { p1.declare_attacker(attacker: bears, target: p2) }.not_to raise_error
    end
  end
end
