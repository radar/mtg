# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OldManWillow do
  include_context "two player game"

  let!(:forests) { Array.new(3) { ResolvePermanent("Forest", owner: p1) } }
  let!(:willow) { ResolvePermanent("Old Man Willow", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:angel) { ResolvePermanent("Serra Angel", owner: p2) }
  let!(:enemy_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def stats(creature) = [creature.power, creature.toughness]

  def make_token
    Magic::Tokens::Treasure.new(game: game, owner: p1).resolve!
  end

  def attack!(attacker: willow)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  describe "power and toughness" do
    it "equal the number of lands you control" do
      game.tick!
      expect(stats(willow)).to eq([3, 3])
    end

    it "grow as your lands enter and ignore the opponent's lands" do
      ResolvePermanent("Swamp", owner: p2)
      game.tick!
      expect(stats(willow)).to eq([3, 3])

      ResolvePermanent("Forest", owner: p1)
      game.tick!
      expect(stats(willow)).to eq([4, 4])
    end

    it "is a legendary Treefolk" do
      expect(willow.type?("Treefolk")).to be(true)
    end
  end

  describe "attack trigger" do
    it "sacrifices another creature, then gives an opponent's creature -2/-2" do
      attack!
      game.resolve_choice!(sacrifice: bears)

      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      game.resolve_choice!(target: angel)
      game.tick!

      expect(stats(angel)).to eq([2, 2])
      expect(stats(enemy_bears)).to eq([2, 2])
    end

    it "can sacrifice a noncreature token" do
      token = make_token
      attack!
      expect(game.choices.first.candidates).to include(token, bears)

      game.resolve_choice!(sacrifice: token)

      expect(p1.permanents).not_to include(token)
      expect(p1.creatures).to include(bears)
      expect(game.choices.first).to be_a(Magic::Cards::OldManWillow::ShrinkChoice)
    end

    it "does not offer Willow itself, a noncreature nontoken or an opponent's permanent" do
      land = forests.first
      attack!

      expect(game.choices.first.candidates).to eq([bears])
      expect(game.choices.first.candidates).not_to include(willow, land, angel)
    end

    it "does nothing when declined" do
      attack!
      game.skip_choice!

      expect(p1.creatures).to include(bears)
      expect(stats(angel)).to eq([4, 4])
      expect(game.choices).to be_empty
    end

    it "only targets creatures an opponent controls" do
      attack!
      game.resolve_choice!(sacrifice: bears)

      expect(game.choices.first.choices).to contain_exactly(angel, enemy_bears)
    end

    it "cannot target a hexproof creature" do
      p2.add_mana(blue: 1)
      p2.cast(card: Card("Dive Down", owner: p2)) { |a| a.pay_mana(blue: 1).targeting(angel) }
      game.stack.resolve!
      game.tick!
      expect(angel).to be_hexproof

      attack!
      game.resolve_choice!(sacrifice: bears)
      game.tick!

      # The only legal target auto-resolves: the 2/2 dies and the hexproof Angel is untouched.
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(stats(angel)).to eq([4, 7]) # Dive Down's +0/+3, with no -2/-2
    end

    it "offers nothing when there is nothing to sacrifice" do
      bears.destroy!
      game.settle!
      attack!

      expect(game.choices).to be_empty
    end

    it "does not trigger when another creature attacks" do
      attack!(attacker: bears)

      expect(game.choices).to be_empty
      expect(p1.creatures).to include(bears)
    end

    it "wears off at end of turn" do
      attack!
      game.resolve_choice!(sacrifice: bears)
      game.resolve_choice!(target: angel)
      game.tick!
      expect(stats(angel)).to eq([2, 2])

      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(stats(angel)).to eq([4, 4])
    end
  end
end
