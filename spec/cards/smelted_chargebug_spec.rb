# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SmeltedChargebug do
  include_context "two player game"

  let!(:bug) { ResolvePermanent("Smelted Chargebug", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:cub) { ResolvePermanent("Bear Cub", owner: p1) }

  def attack(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { |attacker| p1.declare_attacker(attacker: attacker, target: p2) }
    current_turn.attackers_declared!
  end

  it "is a 1/3 artifact creature Insect with menace" do
    expect([bug.power, bug.toughness]).to eq([1, 3])
    expect(bug.type?("Artifact")).to be(true)
    expect(bug.type?("Insect")).to be(true)
    expect(bug.has_keyword?(:menace)).to be(true)
  end

  it "gives you two energy when it enters" do
    expect(p1.energy).to eq(2)
  end

  context "when it attacks with other attackers" do
    before { attack(bug, bears, cub) }

    it "pays {E} to give another target attacking creature +1/+0 and menace" do
      game.resolve_choice!
      game.resolve_choice!(target: bears)
      game.settle!

      expect(p1.energy).to eq(1)
      expect(bears.power).to eq(3)
      expect(bears.has_keyword?(:menace)).to be(true)
      expect(cub.power).to eq(bears.power - 1)
      expect(bug.power).to eq(1)
    end

    it "can't target itself" do
      game.resolve_choice!
      expect(game.choices.first.choices).to contain_exactly(bears, cub)
    end

    it "does nothing and keeps the energy when you decline" do
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(2)
      expect(bears.power).to eq(2)
      expect(bears.has_keyword?(:menace)).to be(false)
    end
  end

  it "skips the choice when there is no other attacking creature" do
    attack(bug)

    expect(game.choices).to be_empty
    expect(p1.energy).to eq(2)
  end

  it "offers nothing when you have no energy" do
    p1.pay_energy!(2)
    attack(bug, bears)

    expect(game.choices).to be_empty
  end

  it "doesn't trigger when another creature attacks alone" do
    attack(bears)

    expect(game.choices).to be_empty
    expect(p1.energy).to eq(2)
  end
end
