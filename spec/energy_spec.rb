# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Energy counters" do
  include_context "two player game"

  let!(:artifact) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def gain(amount) = artifact.trigger_effect(:add_counter, counter_type: "energy", target: p1, amount: amount)

  it "starts at zero" do
    expect(p1.energy).to eq(0)
  end

  it "is gained through the add_counter effect" do
    gain(3)
    game.settle!
    expect(p1.energy).to eq(3)
    expect(p2.energy).to eq(0)
  end

  it "is paid with Costs::PayEnergy" do
    gain(3)
    game.settle!
    cost = Magic::Costs::PayEnergy.new(artifact, amount: 2)
    expect(cost.can_pay?(p1)).to be(true)
    cost.finalize!(p1)
    expect(p1.energy).to eq(1)
  end

  it "can't be paid without enough energy" do
    gain(1)
    game.settle!
    cost = Magic::Costs::PayEnergy.new(artifact, amount: 2)
    expect(cost.can_pay?(p1)).to be(false)
    expect { cost.finalize!(p1) }.to raise_error(/can't pay/)
    expect(p1.energy).to eq(1)
  end

  it "parses 'Pay {E}' as a cost" do
    costs = Magic::Costs::Parser.parse(source: artifact, costs: "{T}, Pay {E}{E}")
    expect(costs.last).to be_a(Magic::Costs::PayEnergy)
    expect(costs.last.amount).to eq(2)
  end

  it "persists across turns" do
    gain(2)
    game.settle!
    2.times { game.next_turn }
    expect(p1.energy).to eq(2)
  end

  describe "Choice::PayEnergy" do
    it "pays when accepted" do
      gain(1)
      game.settle!
      choice = Magic::Choice::PayEnergy.new(actor: artifact)
      expect(choice.can_pay?).to be(true)
      game.add_choice(choice)
      game.resolve_choice!
      expect(p1.energy).to eq(0)
    end

    it "pays nothing when declined, and can't be paid without energy" do
      choice = Magic::Choice::PayEnergy.new(actor: artifact)
      expect(choice.can_pay?).to be(false)
      gain(1)
      game.settle!
      game.add_choice(choice)
      game.skip_choice!
      expect(p1.energy).to eq(1)
    end
  end

  describe "Choice::PayAnyEnergy" do
    let(:paid) { [] }
    let(:choice_class) do
      recorder = paid
      Class.new(Magic::Choice::PayAnyEnergy) { define_method(:paid) { |amount| recorder << amount } }
    end

    before do
      gain(3)
      game.settle!
      game.add_choice(choice_class.new(actor: artifact))
    end

    it "pays the chosen amount" do
      game.resolve_choice!(amount: 2)
      expect(p1.energy).to eq(1)
      expect(paid).to eq([2])
    end

    it "pays everything by default and never more than you have" do
      game.resolve_choice!(amount: 9)
      expect(p1.energy).to eq(0)
      expect(paid).to eq([3])
    end

    it "pays nothing, with an amount of 0, when declined" do
      game.skip_choice!
      expect(p1.energy).to eq(3)
      expect(paid).to eq([0])
    end
  end
end
