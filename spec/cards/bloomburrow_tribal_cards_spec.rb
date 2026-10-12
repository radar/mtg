# frozen_string_literal: true

require "spec_helper"

# Bloomburrow creatures built around creature types, threshold and blinking.
RSpec.describe "Bloomburrow tribal and threshold creatures" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def fill_graveyard(count = 7)
    count.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
  end

  def attack_with(*creatures)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  describe "Harvestrite Host" do
    it "pumps a creature when it enters and draws on the second resolution each turn" do
      host = ResolvePermanent("Harvestrite Host", owner: p1)
      game.resolve_choice!(target: host) if game.choices.any?
      before = p1.hand.count
      ResolvePermanent("Seasoned Warrenguard", owner: p1)
      game.resolve_choice!(target: host) if game.choices.any?
      game.tick!

      expect(host.power).to eq(5)
      expect(p1.hand.count).to eq(before + 1)
    end
  end

  describe "Finneas, Ace Archer" do
    it "puts counters on tokens and Rabbits when it attacks" do
      finneas = ResolvePermanent("Finneas, Ace Archer", owner: p1)
      rabbit = ResolvePermanent("Seasoned Warrenguard", owner: p1)
      token = Magic::Tokens::Fish.new(game: game, owner: p1).resolve!
      other = bear
      attack_with(finneas)

      expect(counters(rabbit)).to eq(1)
      expect(counters(token)).to eq(1)
      expect(counters(other)).to eq(0)
    end

    it "draws a card if creatures you control have total power 10 or greater" do
      finneas = ResolvePermanent("Finneas, Ace Archer", owner: p1)
      2.times { ResolvePermanent("Quaketusk Boar", owner: p1) }
      before = p1.hand.count
      attack_with(finneas)

      expect(p1.hand.count).to eq(before + 1)
    end
  end

  describe "Manifold Mouse" do
    it "gives a Mouse double strike or trample at the beginning of combat" do
      mouse = ResolvePermanent("Manifold Mouse", owner: p1)
      current_turn.beginning_of_combat!
      game.settle!
      game.resolve_choice!(keyword: :double_strike)
      game.tick!

      expect(mouse.keywords).to include(Magic::Cards::Keywords::DOUBLE_STRIKE)
    end
  end

  it "Thundertrap Trainer lets you take a noncreature nonland card from the top four" do
    spell = Card("Titanic Growth", owner: p1)
    p1.library.add(spell)
    ResolvePermanent("Thundertrap Trainer", owner: p1)
    game.resolve_choice!(target: spell)

    expect(p1.hand.cards).to include(spell)
  end

  describe "Thought-Stalker Warlock" do
    it "makes the opponent discard a card of their choice if they haven't lost life" do
      before = p2.hand.count
      ResolvePermanent("Thought-Stalker Warlock", owner: p1)
      game.resolve_choice!(card: p2.hand.first)

      expect(p2.hand.count).to eq(before - 1)
    end

    it "lets you choose a nonland card if they lost life" do
      p2.lose_life(1)
      nonland = Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) }
      ResolvePermanent("Thought-Stalker Warlock", owner: p1)
      game.resolve_choice!(card: nonland)

      expect(p2.graveyard.cards).to include(nonland)
    end
  end

  describe "Thought Shucker" do
    let!(:shucker) { ResolvePermanent("Thought Shucker", owner: p1) }

    it "can't use threshold with fewer than seven cards in the graveyard" do
      expect(shucker.activated_abilities.first.requirements_met?).to be false
    end

    it "grows and draws with seven cards in the graveyard, once" do
      fill_graveyard
      p1.add_mana(blue: 2)
      before = p1.hand.count
      p1.activate_ability(ability: shucker.activated_abilities.first) { _1.pay_mana(generic: { blue: 1 }, blue: 1) }
      game.stack.resolve!

      expect(counters(shucker)).to eq(1)
      expect(p1.hand.count).to eq(before + 1)
      expect(shucker.activated_abilities.first.activation_limit_reached?).to be true
    end
  end

  describe "Nightwhorl Hermit" do
    let!(:hermit) { ResolvePermanent("Nightwhorl Hermit", owner: p1) }

    it "gets +1/+0 and can't be blocked at threshold" do
      expect(hermit.can_be_blocked?(bear(owner: p2))).to be true
      fill_graveyard
      game.tick!

      expect(hermit.power).to eq(2)
      expect(hermit.can_be_blocked?(bear(owner: p2))).to be false
    end
  end

  describe "Mindwhisker" do
    it "surveils at your upkeep and shrinks opposing creatures at threshold" do
      ResolvePermanent("Mindwhisker", owner: p1)
      theirs = bear(owner: p2)
      fill_graveyard
      game.tick!
      expect(theirs.power).to eq(1)

      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
      game.settle!
      expect(game.choices.first).to be_a(Magic::Choice::Surveil)
    end
  end

  describe "Valley Questcaller" do
    it "buffs other Rabbits, Bats, Birds and Mice and scries when they enter" do
      ResolvePermanent("Valley Questcaller", owner: p1)
      rabbit = ResolvePermanent("Seasoned Warrenguard", owner: p1)
      game.tick!

      expect(rabbit.power).to eq(2)
      expect(game.choices.first).to be_a(Magic::Choice::Scry)
    end
  end

  describe "Valley Flamecaller" do
    it "adds 1 to damage dealt by Lizards, Mice, Otters and Raccoons" do
      ResolvePermanent("Valley Flamecaller", owner: p1)
      source = ResolvePermanent("Heartfire Hero", owner: p1)
      source.trigger_effect(:deal_damage, target: p2, damage: 1)
      game.settle!

      expect(p2.life).to eq(18)
    end

    it "doesn't change damage from other sources" do
      ResolvePermanent("Valley Flamecaller", owner: p1)
      other = bear
      other.trigger_effect(:deal_damage, target: p2, damage: 1)
      game.settle!

      expect(p2.life).to eq(19)
    end
  end

  describe "Reptilian Recruiter" do
    it "steals a creature with power 2 or less until end of turn" do
      victim = bear(owner: p2)
      ResolvePermanent("Reptilian Recruiter", owner: p1)
      game.resolve_choice!(target: victim) if game.choices.any?

      expect(victim.controller).to eq(p1)
      expect(victim.keywords).to include(Magic::Cards::Keywords::HASTE)
    end

    it "can't steal a bigger creature without another Lizard" do
      big = ResolvePermanent("Quaketusk Boar", owner: p2)
      ResolvePermanent("Reptilian Recruiter", owner: p1)
      game.resolve_choice!(target: big) if game.choices.any?

      expect(big.controller).to eq(p2)
    end
  end

  describe "Rust-Shield Rampager" do
    it "can't be blocked by creatures with power 2 or less" do
      rampager = ResolvePermanent("Rust-Shield Rampager", owner: p1)

      expect(rampager.can_be_blocked?(bear(owner: p2))).to be false
      expect(rampager.can_be_blocked?(ResolvePermanent("Quaketusk Boar", owner: p2))).to be true
    end
  end

  describe "Salvation Swan" do
    it "blinks a creature without flying and returns it with a flying counter at the next end step" do
      target = bear
      ResolvePermanent("Salvation Swan", owner: p1)
      game.resolve_choice!(target: target) if game.choices.any?
      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")

      current_turn.end!
      game.settle!
      returned = p1.creatures.find { _1.name == "Grizzly Bears" }
      game.tick!

      expect(returned.keywords).to include(Magic::Cards::Keywords::FLYING)
    end
  end

  describe "Skyskipper Duo" do
    it "blinks another creature until the next end step" do
      target = bear
      ResolvePermanent("Skyskipper Duo", owner: p1)
      game.resolve_choice!(target: target) if game.choices.any?
      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")

      current_turn.end!
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end
  end

  describe "Mabel, Heir to Cragflame" do
    it "buffs other Mice and makes the Cragflame Equipment" do
      mabel = ResolvePermanent("Mabel, Heir To Cragflame", owner: p1)
      mouse = ResolvePermanent("Heartfire Hero", owner: p1)
      game.tick!
      expect(mouse.power).to eq(2)

      cragflame = p1.permanents.find { _1.name == "Cragflame" }
      cragflame.attach_to!(mabel)
      game.tick!

      expect(mabel.power).to eq(4)
      expect(mabel.keywords).to include(Magic::Cards::Keywords::HASTE, Magic::Cards::Keywords::TRAMPLE)
    end
  end

  describe "Mistbreath Elder" do
    it "returns another creature at your upkeep to grow" do
      elder = ResolvePermanent("Mistbreath Elder", owner: p1)
      other = bear
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
      game.settle!
      game.resolve_choice!(target: other) if game.choices.any?

      expect(counters(elder)).to eq(1)
      expect(p1.hand.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "may return itself when you control no other creature" do
      elder = ResolvePermanent("Mistbreath Elder", owner: p1)
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
      game.settle!
      game.resolve_choice!

      expect(p1.hand.cards.map(&:name)).to include("Mistbreath Elder")
      expect(elder.zone).to be_nil
    end
  end
end
