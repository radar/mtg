# frozen_string_literal: true

require "spec_helper"

# Bloomburrow creatures with enters-the-battlefield and similar triggers.
RSpec.describe "Bloomburrow enters-the-battlefield creatures" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  describe "Alania's Pathmaker" do
    it "exiles the top card and lets you play it until the end of your next turn" do
      top = p1.library.first
      ResolvePermanent("Alania's Pathmaker", owner: p1)

      expect(game.exile.cards).to include(top)
      expect(game.play_permissions.permits?(top, p1)).to be true
    end
  end

  describe "Clifftop Lookout" do
    it "puts the first land revealed onto the battlefield tapped" do
      p1.library.add(Card("Grizzly Bears", owner: p1))
      before = p1.library.count
      ResolvePermanent("Clifftop Lookout", owner: p1)
      land = p1.permanents.find { _1.land? }

      expect(land).to be_tapped
      expect(p1.library.count).to eq(before - 1)
    end
  end

  describe "Dreamdew Entrancer" do
    it "taps and stuns an opposing creature without drawing" do
      victim = bear(owner: p2)
      before = p1.hand.count
      ResolvePermanent("Dreamdew Entrancer", owner: p1)
      game.resolve_choice!(target: victim) if game.choices.any?

      expect(victim).to be_tapped
      expect(victim.counters.of_type(Magic::Counters::Stun).count).to eq(3)
      expect(p1.hand.count).to eq(before)
    end

    it "draws two cards if you control the creature" do
      mine = bear
      before = p1.hand.count
      ResolvePermanent("Dreamdew Entrancer", owner: p1)
      game.resolve_choice!(target: mine) if game.choices.any?

      expect(p1.hand.count).to eq(before + 2)
    end
  end

  describe "Splash Lasher" do
    it "taps a creature and puts a stun counter on it" do
      victim = bear(owner: p2)
      ResolvePermanent("Splash Lasher", owner: p1)
      game.resolve_choice!(target: victim) if game.choices.any?

      expect(victim).to be_tapped
      expect(victim.counters.of_type(Magic::Counters::Stun).count).to eq(1)
    end
  end

  describe "Pileated Provisioner" do
    it "puts a +1/+1 counter on a creature without flying" do
      target = bear
      ResolvePermanent("Pileated Provisioner", owner: p1)
      game.resolve_choice!(target: target) if game.choices.any?

      expect(counters(target)).to eq(1)
    end
  end

  describe "Plumecreed Mentor" do
    it "puts a counter on a creature without flying when a flyer enters" do
      target = bear
      ResolvePermanent("Plumecreed Mentor", owner: p1)
      game.resolve_choice!(target: target) if game.choices.any?
      expect(counters(target)).to eq(1)

      ResolvePermanent("Pileated Provisioner", owner: p1)
      game.resolve_choice!(target: target) while game.choices.any?
      expect(counters(target)).to be >= 2
    end
  end

  describe "Serra Redeemer" do
    it "puts two counters on another small creature entering" do
      ResolvePermanent("Serra Redeemer", owner: p1)
      small = bear

      expect(counters(small)).to eq(2)
    end

    it "ignores big creatures" do
      ResolvePermanent("Serra Redeemer", owner: p1)
      big = ResolvePermanent("Quaketusk Boar", owner: p1)

      expect(counters(big)).to eq(0)
    end
  end

  describe "Finch Formation" do
    it "gives a creature flying until end of turn" do
      target = bear
      ResolvePermanent("Finch Formation", owner: p1)
      game.resolve_choice!(target: target) if game.choices.any?

      expect(target.keywords).to include(Magic::Cards::Keywords::FLYING)
    end
  end

  describe "Treeguard Duo" do
    it "gives a creature vigilance and +X/+X for the creatures you control" do
      target = bear
      ResolvePermanent("Treeguard Duo", owner: p1)
      game.resolve_choice!(target: target) if game.choices.any?
      game.tick!

      expect(target.power).to eq(2 + 2)
      expect(target.keywords).to include(Magic::Cards::Keywords::VIGILANCE)
    end
  end

  describe "Three Tree Scribe" do
    it "puts a counter on a creature when a creature leaves the battlefield without dying" do
      scribe = ResolvePermanent("Three Tree Scribe", owner: p1)
      leaver = bear
      leaver.exile!
      game.settle!
      game.resolve_choice!(target: scribe) if game.choices.any?

      expect(counters(scribe)).to eq(1)
    end

    it "doesn't trigger when a creature dies" do
      scribe = ResolvePermanent("Three Tree Scribe", owner: p1)
      bear.destroy!
      game.settle!

      expect(counters(scribe)).to eq(0)
    end
  end

  describe "Valley Mightcaller" do
    it "grows when another Frog, Rabbit, Raccoon or Squirrel enters" do
      caller = ResolvePermanent("Valley Mightcaller", owner: p1)
      ResolvePermanent("Seasoned Warrenguard", owner: p1)
      bear

      expect(counters(caller)).to eq(1)
    end
  end

  describe "Honored Dreyleader" do
    it "enters with a counter for each other Squirrel and Food" do
      ResolvePermanent("Valley Rotcaller", owner: p1)
      Magic::Tokens::Food.new(game: game, owner: p1).resolve!
      leader = ResolvePermanent("Honored Dreyleader", owner: p1)

      expect(counters(leader)).to eq(2)
    end

    it "grows when another Squirrel or Food enters" do
      leader = ResolvePermanent("Honored Dreyleader", owner: p1)
      Magic::Tokens::Food.new(game: game, owner: p1).resolve!
      game.settle!

      expect(counters(leader)).to eq(1)
    end
  end
end
