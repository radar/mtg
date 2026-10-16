# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MarionetteApprentice do
  include_context "two player game"

  let!(:apprentice) { ResolvePermanent("Marionette Apprentice", owner: p1) }

  def servos = p1.creatures.select { _1.name == "Servo" }

  it "is a 1/2 Human Artificer" do
    expect([apprentice.power, apprentice.toughness]).to eq([1, 2])
    expect(apprentice.type?("Human")).to be(true)
    expect(apprentice.type?("Artificer")).to be(true)
  end

  describe "Fabricate 1" do
    it "presents a modal choice" do
      expect(game.choices.last).to be_a(described_class::FabricateChoice)
    end

    it "puts a +1/+1 counter on it when that mode is chosen" do
      game.resolve_choice!(mode: described_class::FabricateChoice::COUNTERS)
      game.tick!

      expect([apprentice.power, apprentice.toughness]).to eq([2, 3])
      expect(servos).to be_empty
    end

    it "creates a 1/1 Servo artifact creature token when that mode is chosen" do
      game.resolve_choice!(mode: described_class::FabricateChoice::TOKENS)
      game.tick!

      expect(servos.count).to eq(1)
      expect([servos.first.power, servos.first.toughness]).to eq([1, 1])
      expect(servos.first).to be_artifact
      expect([apprentice.power, apprentice.toughness]).to eq([1, 2])
    end
  end

  describe "graveyard trigger" do
    before do
      game.resolve_choice!(mode: described_class::FabricateChoice::COUNTERS)
      game.tick!
    end

    it "drains each opponent for 1 when another creature you control dies" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.destroy!
      game.settle!

      expect(p2.life).to eq(19)
    end

    it "triggers when an artifact you control is put into a graveyard" do
      ring = ResolvePermanent("Sol Ring", owner: p1)
      ring.destroy!
      game.settle!

      expect(p2.life).to eq(19)
    end

    it "triggers when a Servo token dies" do
      ResolvePermanent("Marionette Apprentice", owner: p1)
      game.resolve_choice!(mode: described_class::FabricateChoice::TOKENS)
      game.settle!
      expect(servos.count).to eq(1)

      servos.first.destroy!
      game.settle!

      # Both Apprentices trigger.
      expect(p2.life).to eq(18)
    end

    it "doesn't trigger when it dies itself" do
      apprentice.destroy!
      game.settle!

      expect(p2.life).to eq(20)
    end

    it "doesn't trigger for an opponent's creature or artifact" do
      ResolvePermanent("Grizzly Bears", owner: p2).destroy!
      ResolvePermanent("Sol Ring", owner: p2).destroy!
      game.settle!

      expect(p2.life).to eq(20)
    end

    it "doesn't trigger for a land you control" do
      ResolvePermanent("Island", owner: p1).destroy!
      game.settle!

      expect(p2.life).to eq(20)
    end

    it "doesn't trigger when a creature you control is exiled" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.exile!
      game.settle!

      expect(p2.life).to eq(20)
    end
  end
end
