# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TritonWavebreaker do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast_bestowed(target)
    p1.add_mana(blue: 2)
    p1.cast_as(:bestowed, card: Card("Triton Wavebreaker", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(target) }
  end

  def triton = game.battlefield.permanents.find { _1.name == "Triton Wavebreaker" }

  it "is a 1/1 Merfolk Wizard enchantment creature with prowess" do
    wavebreaker = ResolvePermanent("Triton Wavebreaker", owner: p1)

    expect(wavebreaker.power).to eq(1)
    expect(wavebreaker.toughness).to eq(1)
    expect(wavebreaker.creature?).to eq(true)
    expect(wavebreaker.enchantment?).to eq(true)
    expect(wavebreaker.prowess?).to eq(true)
  end

  context "cast for its bestow cost" do
    before do
      go_to_main_phase!
      cast_bestowed(bears)
      game.stack.resolve!
      game.settle!
    end

    it "attaches to the creature as an Aura rather than a creature" do
      expect(triton.attached_to).to eq(bears)
      expect(triton.creature?).to eq(false)
      expect(triton.type?("Aura")).to eq(true)
    end

    it "gives the enchanted creature +1/+1 and prowess" do
      expect(bears.power).to eq(3)
      expect(bears.toughness).to eq(3)
      expect(bears.prowess?).to eq(true)
    end

    it "pumps the enchanted creature when its controller casts a noncreature spell" do
      p1.add_mana(red: 1)
      p1.cast(card: Card("Lightning Bolt", owner: p1)) { |a| a.pay_mana(red: 1).targeting(p2) }
      game.settle!
      game.stack.resolve!
      game.settle!

      expect(bears.power).to eq(4)
    end

    it "becomes a creature again when the enchanted creature leaves" do
      bears.destroy!
      game.settle!

      expect(triton.attached_to).to be_nil
      expect(triton.creature?).to eq(true)
      expect(triton.power).to eq(1)
      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end
  end

  it "enters as a creature if its target is gone when it resolves" do
    go_to_main_phase!
    cast_bestowed(bears)
    bears.destroy!
    game.settle!
    game.stack.resolve!
    game.settle!

    expect(triton.attached_to).to be_nil
    expect(triton.creature?).to eq(true)
  end
end
