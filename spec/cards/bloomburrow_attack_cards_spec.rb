# frozen_string_literal: true

require "spec_helper"

# Bloomburrow creatures whose abilities hinge on attacking or on the creature count.
RSpec.describe "Bloomburrow attackers" do
  include_context "two player game"

  before { go_to_main_phase! }

  def attack_with(*creatures)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  describe "Agate-Blade Assassin" do
    it "drains the defending player when it attacks" do
      assassin = ResolvePermanent("Agate-Blade Assassin", owner: p1)
      attack_with(assassin)

      expect(p2.life).to eq(19)
      expect(p1.life).to eq(21)
    end
  end

  describe "Brazen Collector" do
    it "adds {R} when it attacks" do
      collector = ResolvePermanent("Brazen Collector", owner: p1)
      attack_with(collector)

      expect(p1.mana_pool[:red]).to eq(1)
    end
  end

  describe "Bria, Riptide Rogue" do
    let!(:bria) { ResolvePermanent("Bria, Riptide Rogue", owner: p1) }
    let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def cast_growth
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(other) }
      game.settle!
    end

    it "gives other creatures prowess" do
      cast_growth
      game.resolve_choice!(target: other)
      game.stack.resolve!
      game.tick!

      expect(other.power).to eq(2 + 4 + 1)
    end

    it "makes a creature unblockable when you cast a noncreature spell" do
      cast_growth
      game.resolve_choice!(target: other)

      expect(other.can_be_blocked?(ResolvePermanent("Grizzly Bears", owner: p2))).to be false
    end

    it "has prowess itself" do
      cast_growth
      game.resolve_choice!(target: other)
      game.stack.resolve!
      game.tick!

      expect(bria.power).to eq(4)
    end
  end

  describe "Burrowguard Mentor" do
    it "has power and toughness equal to the number of creatures you control" do
      mentor = ResolvePermanent("Burrowguard Mentor", owner: p1)
      game.tick!
      expect([mentor.power, mentor.toughness]).to eq([1, 1])

      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p2)
      game.tick!
      expect([mentor.power, mentor.toughness]).to eq([2, 2])
    end
  end

  describe "Seasoned Warrenguard" do
    it "gets +2/+0 when it attacks while you control a token" do
      warrenguard = ResolvePermanent("Seasoned Warrenguard", owner: p1)
      Magic::Tokens::Food.new(game: game, owner: p1).resolve!
      attack_with(warrenguard)

      expect(warrenguard.power).to eq(3)
    end

    it "doesn't without a token" do
      warrenguard = ResolvePermanent("Seasoned Warrenguard", owner: p1)
      attack_with(warrenguard)

      expect(warrenguard.power).to eq(1)
    end
  end

  describe "Valley Rotcaller" do
    it "drains for each other Squirrel, Bat, Lizard and Rat you control" do
      rotcaller = ResolvePermanent("Valley Rotcaller", owner: p1)
      ResolvePermanent("Agate-Blade Assassin", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(rotcaller)

      expect(p2.life).to eq(19)
      expect(p1.life).to eq(21)
    end
  end

  describe "Waterspout Warden" do
    it "gains flying when attacking after another creature entered this turn" do
      warden = ResolvePermanent("Waterspout Warden", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(warden)

      expect(warden.keywords).to include(Magic::Cards::Keywords::FLYING)
    end

    it "doesn't gain flying otherwise" do
      go_to_main_phase_for!(p1)
      warden = ResolvePermanent("Waterspout Warden", owner: p1)
      current_turn.events.clear
      attack_with(warden)

      expect(warden.keywords).not_to include(Magic::Cards::Keywords::FLYING)
    end
  end

  describe "Seedpod Squire" do
    it "pumps a non-flying creature when it attacks" do
      squire = ResolvePermanent("Seedpod Squire", owner: p1)
      bear = ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(squire)
      game.resolve_choice!(target: bear) if game.choices.any?
      game.tick!

      expect(bear.power).to eq(3)
    end
  end

  describe "Hazardroot Herbalist" do
    it "gives a creature +1/+0 whenever you attack, and deathtouch if it is a token" do
      herbalist = ResolvePermanent("Hazardroot Herbalist", owner: p1)
      token = Magic::Tokens::Fish.new(game: game, owner: p1).resolve!
      attack_with(herbalist)
      game.resolve_choice!(target: token)
      game.tick!

      expect(token.power).to eq(2)
      expect(token.keywords).to include(Magic::Cards::Keywords::DEATHTOUCH)
    end
  end
end
