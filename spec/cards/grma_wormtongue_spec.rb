# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrmaWormtongue do
  include_context "two player game"

  let!(:grima) { ResolvePermanent("Gríma Wormtongue", owner: p1) }

  def army = p1.creatures.find { _1.type?("Army") }

  def drain(victim, target)
    p1.activate_ability(ability: grima.activated_abilities.first) do |a|
      a.pay_sacrifice(victim)
      a.targeting(target)
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a 1/4 legendary Human Advisor" do
    expect([grima.power, grima.toughness]).to eq([1, 4])
    expect(grima.type?("Advisor")).to eq(true)
  end

  it "stops opponents gaining life but not its controller" do
    p2.gain_life(3)
    p1.gain_life(3)
    expect(p2.life).to eq(20)
    expect(p1.life).to eq(23)
  end

  it "stops the opponent gaining life only while it is on the battlefield" do
    grima.destroy!
    game.settle!
    p2.gain_life(3)
    expect(p2.life).to eq(23)
  end

  context "sacrificing another creature" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "taps, sacrifices the creature and makes the target player lose 1 life" do
      drain(bears, p2)
      expect(p2.life).to eq(19)
      expect(grima.tapped?).to eq(true)
      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "can target its controller" do
      drain(bears, p1)
      expect(p1.life).to eq(19)
    end

    it "does not amass when the creature was not legendary" do
      drain(bears, p2)
      expect(army).to be_nil
    end

    it "amasses Orcs 2 when the creature was legendary" do
      thorin = ResolvePermanent("Thorin Oakenshield", owner: p1)
      drain(thorin, p2)
      expect(p2.life).to eq(19)
      expect(army.type?("Orc")).to eq(true)
      expect(army.power).to eq(2)
    end

    it "cannot sacrifice itself" do
      expect { drain(grima, p2) }.to raise_error(StandardError)
    end
  end
end
