# frozen_string_literal: true

require "spec_helper"

# Bloomburrow's Bats and the other cards that care whether you gained or lost life this turn.
RSpec.describe "Bloomburrow life matters" do
  include_context "two player game"

  before { go_to_main_phase! }

  def gain_life(player = p1, amount = 1)
    player.gain_life(amount)
    game.settle!
  end

  def lose_life(player = p1, amount = 1)
    player.lose_life(amount)
    game.settle!
  end

  describe "Essence Channeler" do
    let!(:channeler) { ResolvePermanent("Essence Channeler", owner: p1) }

    it "has flying and vigilance only once you've lost life this turn" do
      game.tick!
      expect(channeler.keywords).not_to include(Magic::Cards::Keywords::FLYING)

      lose_life
      game.tick!
      expect(channeler.keywords).to include(Magic::Cards::Keywords::FLYING, Magic::Cards::Keywords::VIGILANCE)
    end

    it "gets a +1/+1 counter whenever you gain life" do
      gain_life
      game.tick!

      expect(channeler.power).to eq(3)
    end

    it "puts its counters on a creature you control when it dies" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      gain_life
      channeler.destroy!
      game.settle!
      game.resolve_choice!(target: other) if game.choices.any?
      game.tick!

      expect(other.power).to eq(3)
    end
  end

  describe "Moonstone Harbinger" do
    let!(:harbinger) { ResolvePermanent("Moonstone Harbinger", owner: p1) }

    it "pumps Bats once each turn when you gain or lose life during your turn" do
      gain_life
      lose_life
      game.tick!

      expect(harbinger.power).to eq(2)
      expect(harbinger.keywords).to include(Magic::Cards::Keywords::DEATHTOUCH)
    end

    it "ignores life changes on the opponent's turn" do
      go_to_main_phase_for!(p2)
      gain_life
      game.tick!

      expect(harbinger.power).to eq(1)
    end
  end

  describe "Wax-Wane Witness" do
    it "gets +1/+0 for each life change during your turn" do
      witness = ResolvePermanent("Wax-Wane Witness", owner: p1)
      gain_life
      lose_life
      game.tick!

      expect(witness.power).to eq(4)
    end
  end

  describe "Starlit Soothsayer" do
    it "surveils 1 at your end step if you gained or lost life" do
      ResolvePermanent("Starlit Soothsayer", owner: p1)
      gain_life
      current_turn.end!
      game.settle!

      expect(game.choices.first).to be_a(Magic::Choice::Surveil)
    end

    it "does nothing if you didn't" do
      ResolvePermanent("Starlit Soothsayer", owner: p1)
      current_turn.end!
      game.settle!

      expect(game.choices).to be_empty
    end
  end

  describe "Star Charter" do
    it "looks at the top four cards at your end step if you gained life" do
      ResolvePermanent("Star Charter", owner: p1)
      gain_life
      current_turn.end!
      game.settle!

      expect(game.choices.first).to be_a(Magic::Choice::LookAtTopCards)
    end
  end

  describe "Starseer Mentor" do
    it "has an opponent lose 3 life unless they sacrifice or discard" do
      ResolvePermanent("Starseer Mentor", owner: p1)
      lose_life
      current_turn.end!
      game.settle!
      game.skip_choice!

      expect(p2.life).to eq(17)
    end

    it "lets the opponent discard a card instead" do
      ResolvePermanent("Starseer Mentor", owner: p1)
      lose_life
      current_turn.end!
      game.settle!
      game.resolve_choice!(discard: p2.hand.first)

      expect(p2.life).to eq(20)
    end
  end

  describe "Thornplate Intimidator" do
    it "has the opponent lose 3 life unless they discard or sacrifice" do
      ResolvePermanent("Thornplate Intimidator", owner: p1)
      game.skip_choice!

      expect(p2.life).to eq(17)
    end
  end

  describe "Lunar Convocation" do
    let!(:convocation) { ResolvePermanent("Lunar Convocation", owner: p1) }

    it "drains each opponent for 1 at your end step if you gained life" do
      gain_life
      current_turn.end!
      game.settle!

      expect(p2.life).to eq(19)
    end

    it "creates a Bat if you gained and lost life" do
      gain_life
      lose_life
      current_turn.end!
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Bat")
    end

    it "does nothing if you did neither" do
      current_turn.end!
      game.settle!

      expect(p2.life).to eq(20)
      expect(p1.creatures).to be_empty
    end

    it "draws a card for {1}{B} and 2 life" do
      p1.add_mana(black: 2)
      before = p1.hand.count
      p1.activate_ability(ability: convocation.activated_abilities.first) { _1.pay_mana(generic: { black: 1 }, black: 1) }
      game.stack.resolve!

      expect(p1.hand.count).to eq(before + 1)
      expect(p1.life).to eq(18)
    end
  end
end
