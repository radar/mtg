# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DollmakersShopPorcelainGallery do
  include_context "two player game"

  def toys = p1.creatures.select { _1.type?("Toy") }

  def attack_with(*attackers)
    skip_to_combat!
    current_turn.declare_attackers!
    attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
    current_turn.attackers_declared!
    game.tick!
  end

  context "Dollmaker's Shop" do
    let!(:room) { ResolvePermanent("Dollmakers Shop Porcelain Gallery", doors: [:left]) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:other_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "creates a 1/1 white Toy artifact creature token when non-Toy creatures attack a player" do
      attack_with(bears)

      expect(toys.size).to eq(1)
      expect([toys.first.power, toys.first.toughness]).to eq([1, 1])
      expect(toys.first.colors).to eq([:white])
      expect(toys.first.types).to include(Magic::Types::Artifact)
    end

    it "creates only one token however many creatures attack" do
      attack_with(bears, other_bears)

      expect(toys.size).to eq(1)
    end

    it "does not trigger when only Toys attack" do
      toy = ResolvePermanent("Friendly Teddy", owner: p1)
      attack_with(toy)

      expect(toys.size).to eq(1) # just the Teddy
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:left)
      attack_with(bears)

      expect(toys).to be_empty
    end
  end

  context "Porcelain Gallery" do
    let!(:room) { ResolvePermanent("Dollmakers Shop Porcelain Gallery", doors: [:right]) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "sets base power and toughness of your creatures to the number of creatures you control" do
      game.tick!
      expect([bears.power, bears.toughness]).to eq([1, 1])

      ResolvePermanent("Grizzly Bears", owner: p1)
      game.tick!
      expect([bears.power, bears.toughness]).to eq([2, 2])
    end

    it "does not affect creatures your opponents control" do
      game.tick!
      expect([theirs.power, theirs.toughness]).to eq([2, 2])
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:right)
      game.tick!

      expect(bears.power).to eq(2)
    end
  end
end
