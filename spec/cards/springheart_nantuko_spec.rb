# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpringheartNantuko do
  include_context "two player game"

  before { go_to_main_phase! }

  def insects = p1.creatures.select { _1.name == "Insect" }

  context "as a creature" do
    let!(:nantuko) { ResolvePermanent("Springheart Nantuko", owner: p1) }

    it "creates a 1/1 Insect when a land enters" do
      ResolvePermanent("Forest", owner: p1)
      game.settle!

      expect(insects.size).to eq(1)
      expect([insects.first.power, insects.first.toughness]).to eq([1, 1])
    end

    it "makes no Insect when a land enters under an opponent's control" do
      ResolvePermanent("Forest", owner: p2)
      game.settle!

      expect(insects).to be_empty
    end
  end

  context "bestowed on a creature an opponent controls" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      p1.add_mana(green: 2)
      p1.cast_as(:bestowed, card: Card("Springheart Nantuko", owner: p1)) do |a|
        a.pay_mana(generic: { green: 1 }, green: 1).targeting(bears)
      end
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "only creates an Insect, with no choice to copy the creature" do
      p1.add_mana(green: 2)
      ResolvePermanent("Forest", owner: p1)
      game.settle!

      expect(game.choices).to be_empty
      expect(insects.size).to eq(1)
      expect(p2.creatures.count { _1.name == "Grizzly Bears" }).to eq(1)
      expect(p1.creatures.count { _1.name == "Grizzly Bears" }).to eq(0)
    end
  end

  context "bestowed on a creature you control" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      p1.add_mana(green: 2)
      p1.cast_as(:bestowed, card: Card("Springheart Nantuko", owner: p1)) do |a|
        a.pay_mana(generic: { green: 1 }, green: 1).targeting(bears)
      end
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "gives the enchanted creature +1/+1" do
      expect([bears.power, bears.toughness]).to eq([3, 3])
    end

    it "creates a token copy of the creature when you pay {1}{G} on landfall" do
      p1.add_mana(green: 2)
      ResolvePermanent("Forest", owner: p1)
      game.settle!
      game.resolve_choice!(payment: { generic: { green: 1 }, green: 1 })
      game.settle!

      expect(p1.creatures.count { _1.name == "Grizzly Bears" }).to eq(2)
      expect(insects).to be_empty
    end

    it "creates an Insect instead when you decline to pay" do
      p1.add_mana(green: 2)
      ResolvePermanent("Forest", owner: p1)
      game.settle!
      game.skip_choice!
      game.settle!

      expect(p1.creatures.count { _1.name == "Grizzly Bears" }).to eq(1)
      expect(insects.size).to eq(1)
    end

    it "creates an Insect when you cannot pay" do
      ResolvePermanent("Forest", owner: p1)
      game.settle!

      expect(insects.size).to eq(1)
    end
  end
end
