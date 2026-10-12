# frozen_string_literal: true

require "spec_helper"

# Bloomburrow's legends and other cards with several moving parts.
RSpec.describe "Bloomburrow legends" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def attack_with(*creatures)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    creatures.each { current_turn.declare_attacker(_1, target: p2) }
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  describe "Keen-Eyed Curator" do
    let!(:curator) { ResolvePermanent("Keen-Eyed Curator", owner: p1) }

    it "exiles a card from a graveyard for {1}" do
      card = Card("Grizzly Bears", owner: p2).tap { p2.graveyard.add(_1) }
      p1.add_mana(green: 1)
      p1.activate_ability(ability: curator.activated_abilities.first) do |action|
        action.pay_mana(generic: { green: 1 })
        action.targeting(card)
      end
      game.stack.resolve!

      expect(game.exile.cards).to include(card)
      expect(curator.exiled_cards).to include(card)
    end

    it "gets +4/+4 and trample with four card types exiled with it" do
      %w[Grizzly\ Bears Short\ Bow Titanic\ Growth Forest].each do |name|
        card = Card(name, owner: p2).tap { p2.graveyard.add(_1) }
        curator.exiled_cards << card
        card.exile!
      end
      game.tick!

      expect(curator.power).to eq(7)
      expect(curator.keywords).to include(Magic::Cards::Keywords::TRAMPLE)
    end
  end

  describe "Kitsa, Otterball Elite" do
    let!(:kitsa) { ResolvePermanent("Kitsa, Otterball Elite", owner: p1) }

    it "loots for {T}" do
      before = p1.hand.count
      p1.activate_ability(ability: kitsa.activated_abilities.first)
      game.stack.resolve!
      game.resolve_choice!(card: p1.hand.first)

      expect(p1.hand.count).to eq(before)
    end

    it "can only copy a spell while its power is 3 or greater" do
      expect(kitsa.activated_abilities.last.requirements_met?).to be false
      kitsa.add_counter("+1/+1", amount: 2)
      game.tick!
      expect(kitsa.activated_abilities.last.requirements_met?).to be true
    end
  end

  describe "Persistent Marshstalker" do
    it "gets +1/+0 for each other Rat" do
      stalker = ResolvePermanent("Persistent Marshstalker", owner: p1)
      ResolvePermanent("Valley Rotcaller", owner: p1)
      rat = ResolvePermanent("Thought Shucker", owner: p1)
      game.tick!

      expect(rat.type?("Rat")).to be true
      expect(stalker.power).to eq(4)
    end

    it "returns from the graveyard tapped and attacking at threshold" do
      stalker_card = Card("Persistent Marshstalker", owner: p1).tap { p1.graveyard.add(_1) }
      6.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
      rat = ResolvePermanent("Thought Shucker", owner: p1)
      p1.add_mana(black: 3)
      attack_with(rat)
      game.resolve_choice!

      returned = p1.creatures.find { _1.name == "Persistent Marshstalker" }
      expect(returned).to be_tapped
      expect(stalker_card.zone).to be_nil.or be_a(Magic::Zones::Battlefield)
    end
  end

  describe "Lumra, Bellow of the Woods" do
    it "mills four and returns lands from the graveyard tapped" do
      2.times { ResolvePermanent("Forest", owner: p1) }
      lumra = ResolvePermanent("Lumra, Bellow Of The Woods", owner: p1)
      game.tick!

      lands = p1.permanents.select(&:land?)
      expect(lands.size).to eq(6)
      expect(lands.count(&:tapped?)).to eq(4)
      expect(lumra.power).to eq(6)
    end
  end

  describe "Muerra, Trash Tactician" do
    let!(:muerra) { ResolvePermanent("Muerra, Trash Tactician", owner: p1) }

    it "adds mana for each Raccoon at your first main phase" do
      game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
      game.settle!
      game.resolve_choice!(colors: [:red])

      expect(p1.mana_pool[:red]).to eq(1)
    end

    it "gains 3 life when you expend 4" do
      p1.add_mana(green: 4)
      p1.pay_mana(green: 4)
      game.settle!

      expect(p1.life).to eq(23)
    end
  end

  describe "Wick, the Whorled Mind" do
    it "creates a Snail when a Rat enters, then grows it" do
      ResolvePermanent("Wick, The Whorled Mind", owner: p1)
      game.settle!
      snail = p1.creatures.find { _1.name == "Snail" }
      expect(snail).not_to be_nil

      ResolvePermanent("Thought Shucker", owner: p1)
      game.settle!
      game.resolve_choice!(target: snail) if game.choices.any?
      expect(counters(snail)).to eq(1)
    end

    it "sacrifices a Snail to deal damage and draw cards equal to its power" do
      wick = ResolvePermanent("Wick, The Whorled Mind", owner: p1)
      game.settle!
      snail = p1.creatures.find { _1.name == "Snail" }
      snail.add_counter("+1/+1")
      game.tick!
      p1.add_mana(blue: 1, black: 1, red: 1)
      before = p1.hand.count
      p1.activate_ability(ability: wick.activated_abilities.first) do |action|
        action.pay_mana(blue: 1, black: 1, red: 1)
        action.pay_sacrifice(snail)
      end
      game.stack.resolve!

      expect(p2.life).to eq(18)
      expect(p1.hand.count).to eq(before + 2)
    end
  end

  describe "Vren, the Relentless" do
    it "exiles dying opposing creatures and makes Rats at end step" do
      ResolvePermanent("Vren, The Relentless", owner: p1)
      victim = bear(owner: p2)
      victim.destroy!
      game.settle!
      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")

      current_turn.end!
      game.settle!
      rats = p1.creatures.select { _1.name == "Rat" }
      expect(rats.size).to eq(1)
    end

    it "makes Rats that grow with other Rats" do
      ResolvePermanent("Vren, The Relentless", owner: p1)
      2.times { bear(owner: p2).destroy! }
      game.settle!
      current_turn.end!
      game.settle!
      game.tick!
      rats = p1.creatures.select { _1.name == "Rat" }

      expect(rats.map(&:power)).to all(eq(3)) # 1/1 plus one for the other token and one for Vren, a Rat
    end
  end

  describe "Zoraline, Cosmos Caller" do
    it "gains 1 life whenever a Bat you control attacks" do
      zoraline = ResolvePermanent("Zoraline, Cosmos Caller", owner: p1)
      game.skip_choice! while game.choices.any?
      attack_with(zoraline)
      game.skip_choice! while game.choices.any?

      expect(p1.life).to eq(21)
    end

    it "may pay {W}{B} and 2 life to return a cheap permanent with a finality counter" do
      target = Card("Short Bow", owner: p1).tap { p1.graveyard.add(_1) }
      p1.add_mana(white: 1, black: 1)
      ResolvePermanent("Zoraline, Cosmos Caller", owner: p1)
      game.resolve_choice!
      game.resolve_choice!(target: target) if game.choices.any?
      returned = p1.permanents.find { _1.name == "Short Bow" }

      expect(returned.counters.of_type(Magic::Counters["finality"]).count).to eq(1)
      expect(p1.life).to eq(18)
    end
  end

  describe "Ygra, Eater of All" do
    it "makes other creatures Food with a Food ability and grows when a Food dies" do
      ygra = ResolvePermanent("Ygra, Eater Of All", owner: p1)
      other = bear
      game.tick!
      expect(other.type?("Food")).to be true
      expect(ygra.type?("Food")).to be false

      other.destroy!
      game.settle!
      game.tick!
      expect(ygra.power).to eq(8)
    end
  end
end
