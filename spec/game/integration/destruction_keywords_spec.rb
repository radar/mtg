# frozen_string_literal: true

require "spec_helper"
require_relative "../../card_parser/card_parser_helpers"

RSpec.describe "Destruction keywords: indestructible, regeneration and protection from damage" do
  include CardParserHelpers
  include_context "two player game"

  def creature(text, owner:)
    name = text.lines.first[/\A(.+?) \{/, 1]
    load_card(text)
    ResolvePermanent(name, owner: owner)
  end

  def deal_damage(source, target, amount)
    source.trigger_effect(:deal_damage, source: source, target: target, damage: amount)
    game.tick!
  end

  let!(:bear) { creature("Destroy Test Bear {1}{G}\nCreature — Bear\n2/2\n", owner: p1) }
  let!(:deathtoucher) { creature("Destroy Test Viper {B}\nCreature — Snake\nDeathtouch\n1/1\n", owner: p2) }

  context "indestructible" do
    let!(:target) { creature("Indestructible Test Golem {3}\nArtifact Creature — Golem\nIndestructible\n1/1\n", owner: p1) }

    it "survives a destroy effect" do
      expect(target.destroy!).to eq(false)
      expect(target.zone).to be_battlefield
    end

    it "survives lethal damage" do
      deal_damage(bear, target, 5)

      expect(target.zone).to be_battlefield
    end

    it "survives deathtouch damage" do
      deal_damage(deathtoucher, target, 1)
      game.tick!

      expect(target.zone).to be_battlefield
    end
  end

  context "regeneration" do
    before { go_to_main_phase! }

    it "does nothing until it would be destroyed" do
      bear.regenerate!

      expect(bear).not_to be_tapped
      expect(bear.zone).to be_battlefield
    end

    it "replaces a destroy effect: the permanent stays, tapped" do
      bear.regenerate!

      expect(bear.destroy!).to eq(false)
      expect(bear.zone).to be_battlefield
      expect(bear).to be_tapped
    end

    it "replaces destruction by lethal damage and removes the damage" do
      bear.regenerate!
      deal_damage(deathtoucher, bear, 2)

      expect(bear.zone).to be_battlefield
      expect(bear.damage).to eq(0)
    end

    it "is a one-time shield" do
      bear.regenerate!
      bear.destroy!
      bear.untap!

      expect(bear.destroy!).to eq(true)
      expect(game.battlefield.creatures).not_to include(bear)
    end

    it "stacks: two shields save it twice" do
      2.times { bear.regenerate! }
      2.times { bear.destroy! }

      expect(bear.zone).to be_battlefield
    end

    it "expires at end of turn" do
      bear.regenerate!
      bear.cleanup!

      expect(bear.destroy!).to eq(true)
    end

    it "removes an attacker from combat" do
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(bear, target: p2)
      bear.regenerate!
      bear.destroy!

      expect(current_turn.attacks.map(&:attacker)).not_to include(bear)
    end

    it "lets a regenerating blocker survive combat damage" do
      ogre = creature("Destroy Test Ogre {3}{R}\nCreature — Ogre\n4/4\n", owner: p2)
      bear.regenerate!
      game.next_turn
      game.next_turn
      go_to_main_phase!
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(ogre, target: p1)
      current_turn.attackers_declared!
      current_turn.declare_blocker(bear, attacker: ogre)
      bear.regenerate!
      current_turn.combat_damage!
      game.tick!

      expect(bear.zone).to be_battlefield
      expect(bear).to be_tapped
    end
  end

  context "protection from a color" do
    let!(:target) { creature("Protection Damage Test Knight {1}{W}\nCreature — Knight\nProtection from red\n2/2\n", owner: p1) }
    let!(:red_source) { creature("Damage Test Goblin {R}\nCreature — Goblin\n2/2\n", owner: p2) }

    it "prevents damage from a source of that color" do
      deal_damage(red_source, target, 2)

      expect(target.damage).to eq(0)
      expect(target.zone).to be_battlefield
    end

    it "does not prevent damage from other sources" do
      deal_damage(deathtoucher, target, 1)

      expect(target.damage).to eq(1)
    end

    it "prevents combat damage from a source of that color" do
      game.next_turn
      go_to_main_phase!
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(red_source, target: p1)
      current_turn.attackers_declared!
      current_turn.declare_blocker(target, attacker: red_source)
      current_turn.combat_damage!

      expect(target.damage).to eq(0)
      expect(red_source.damage).to eq(2)
    end
  end
end
