# frozen_string_literal: true

require "spec_helper"

# Bloomburrow's gift cards: as you cast one you may promise an opponent a gift, which they receive as
# the spell resolves; its other effects then check whether the gift was promised.
RSpec.describe "Gift cards" do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast(name, mana:, gift: false, targets: [], player: p1)
    card = Card(name, owner: player)
    player.add_mana(**mana)
    player.cast(card: card) do |action|
      action.promise_gift if gift
      action.auto_pay_mana
      action.targeting(*targets) if targets.any?
      yield action if block_given?
    end
    game.settle!
    game.stack.resolve!
    game.settle!
    game.tick!
    card
  end

  def permanent_names(player) = player.permanents.map(&:name)

  describe "the gift itself" do
    it "gives a card" do
      before = p2.hand.count
      cast("Dawn's Truce", mana: { white: 2 }, gift: true)

      expect(p2.hand.count).to eq(before + 1)
    end

    it "gives nothing when not promised" do
      before = p2.hand.count
      cast("Dawn's Truce", mana: { white: 2 })

      expect(p2.hand.count).to eq(before)
    end

    it "gives a Food" do
      cast("Crumb And Get It", mana: { white: 1 }, gift: true, targets: [mine])

      expect(permanent_names(p2)).to include("Food")
    end

    it "gives a Treasure" do
      cast("Blooming Blast", mana: { red: 2 }, gift: true, targets: [bear])

      expect(permanent_names(p2)).to include("Treasure")
    end

    it "gives a tapped Fish" do
      cast("Into The Flood Maw", mana: { blue: 1 }, gift: true, targets: [bear])
      fish = p2.permanents.find { _1.name == "Fish" }

      expect(fish).to be_tapped
    end

    it "can only be promised by a card with a gift" do
      action = p1.prepare_cast(card: Card("Titanic Growth", owner: p1))

      expect { action.promise_gift }.to raise_error(/has no gift/)
    end
  end

  describe "Blooming Blast" do
    it "deals 2 damage to the creature" do
      cast("Blooming Blast", mana: { red: 2 }, targets: [bear])

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(p2.life).to eq(20)
    end

    it "also deals 3 damage to its controller when the gift was promised" do
      cast("Blooming Blast", mana: { red: 2 }, gift: true, targets: [bear])

      expect(p2.life).to eq(17)
    end
  end

  describe "Crumb and Get It" do
    it "gives +2/+2" do
      cast("Crumb And Get It", mana: { white: 1 }, targets: [mine])

      expect(mine.power).to eq(4)
      expect(mine.keywords).not_to include(Magic::Cards::Keywords::INDESTRUCTIBLE)
    end

    it "also grants indestructible when the gift was promised" do
      cast("Crumb And Get It", mana: { white: 1 }, gift: true, targets: [mine])

      expect(mine.keywords).to include(Magic::Cards::Keywords::INDESTRUCTIBLE)
    end
  end

  describe "Consumed by Greed" do
    let!(:big) { ResolvePermanent("Nettle Guard", owner: p2) }

    it "makes the opponent sacrifice the creature with the greatest power" do
      cast("Consumed By Greed", mana: { black: 3 }, targets: [p2])

      expect(p2.graveyard.cards.map(&:name)).to eq(["Nettle Guard"])
      expect(bear.zone).to be_battlefield
    end

    it "returns a creature card from your graveyard when the gift was promised" do
      dead = Card("Grizzly Bears", owner: p1)
      p1.graveyard.add(dead)
      cast("Consumed By Greed", mana: { black: 3 }, gift: true, targets: [p2, dead])

      expect(p1.hand.cards).to include(dead)
    end
  end

  describe "Dawn's Truce" do
    it "gives you and your permanents hexproof" do
      mine
      cast("Dawn's Truce", mana: { white: 2 })

      expect(p1).to be_hexproof
      expect(mine.keywords).to include(Magic::Cards::Keywords::HEXPROOF)
      expect(mine.keywords).not_to include(Magic::Cards::Keywords::INDESTRUCTIBLE)
    end

    it "also gives indestructible when the gift was promised" do
      mine
      cast("Dawn's Truce", mana: { white: 2 }, gift: true)

      expect(mine.keywords).to include(Magic::Cards::Keywords::INDESTRUCTIBLE)
    end
  end

  describe "Dewdrop Cure" do
    let(:cards) { Array.new(3) { Card("Short Bow", owner: p1) } }
    let(:creatures) { Array.new(3) { Card("Grizzly Bears", owner: p1) } }

    before { creatures.each { p1.graveyard.add(_1) } }

    it "returns up to two creature cards with mana value 2 or less" do
      cast("Dewdrop Cure", mana: { white: 3 }, targets: creatures.first(2))

      expect(p1.creatures.count).to eq(2)
    end

    it "returns up to three when the gift was promised" do
      cast("Dewdrop Cure", mana: { white: 3 }, gift: true, targets: creatures)

      expect(p1.creatures.count).to eq(3)
    end
  end

  describe "Into the Flood Maw" do
    it "returns a creature an opponent controls to its owner's hand" do
      cast("Into The Flood Maw", mana: { blue: 1 }, targets: [bear])

      expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "can return any nonland permanent when the gift was promised" do
      bow = ResolvePermanent("Short Bow", owner: p2)
      cast("Into The Flood Maw", mana: { blue: 1 }, gift: true, targets: [bow])

      expect(p2.hand.cards.map(&:name)).to include("Short Bow")
    end

    it "can't return a noncreature permanent without the gift" do
      bow = ResolvePermanent("Short Bow", owner: p2)

      expect { cast("Into The Flood Maw", mana: { blue: 1 }, targets: [bow]) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end
  end

  describe "Long River's Pull" do
    before { go_to_main_phase_for!(p2) }

    def p2_casts(name, mana)
      p2.add_mana(**mana)
      p2.cast(card: Card(name, owner: p2)) { _1.auto_pay_mana; _1.targeting(*([bear] * 0)) }
    end

    it "counters a creature spell" do
      p2.add_mana(white: 2)
      p2.cast(card: Card("Brightblade Stoat", owner: p2)) { _1.auto_pay_mana }
      spell = game.stack.spells.first
      cast("Long River's Pull", mana: { blue: 2 }, targets: [spell])

      expect(p2.graveyard.cards.map(&:name)).to include("Brightblade Stoat")
    end

    it "can counter any spell when the gift was promised" do
      p2.add_mana(green: 2)
      p2.cast(card: Card("Titanic Growth", owner: p2)) { _1.auto_pay_mana; _1.targeting(bear) }
      spell = game.stack.spells.first
      cast("Long River's Pull", mana: { blue: 2 }, gift: true, targets: [spell])

      expect(p2.graveyard.cards.map(&:name)).to include("Titanic Growth")
    end
  end

  describe "Kitnap" do
    it "taps the creature, stuns it and gives you control" do
      cast("Kitnap", mana: { blue: 4 }, targets: [bear])

      expect(bear.controller).to eq(p1)
      expect(bear).to be_tapped
      expect(bear.counters.of_type(Magic::Counters::Stun).count).to eq(3)
    end

    it "doesn't stun it when the gift was promised" do
      cast("Kitnap", mana: { blue: 4 }, gift: true, targets: [bear])

      expect(bear).to be_tapped
      expect(bear.counters.of_type(Magic::Counters::Stun).count).to eq(0)
    end
  end

  describe "Longstalk Brawl" do
    it "makes the creatures fight" do
      big = ResolvePermanent("Nettle Guard", owner: p1)
      cast("Longstalk Brawl", mana: { green: 1 }, targets: [big, bear])

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "puts a +1/+1 counter on your creature first when the gift was promised" do
      cast("Longstalk Brawl", mana: { green: 1 }, gift: true, targets: [mine, bear])

      expect(mine.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
      expect(mine.zone).to be_battlefield
    end
  end

  describe "Mind Spiral" do
    it "has target player draw three cards" do
      before = p1.hand.count
      cast("Mind Spiral", mana: { blue: 5 }, targets: [p1])

      expect(p1.hand.count).to eq(before + 3)
    end

    it "also taps and stuns a creature when the gift was promised" do
      cast("Mind Spiral", mana: { blue: 5 }, gift: true, targets: [p1, bear])

      expect(bear).to be_tapped
      expect(bear.counters.of_type(Magic::Counters::Stun).count).to eq(1)
    end
  end

  describe "Nocturnal Hunger" do
    it "destroys the creature and costs 2 life without the gift" do
      cast("Nocturnal Hunger", mana: { black: 3 }, targets: [bear])

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(p1.life).to eq(18)
    end

    it "costs no life when the gift was promised" do
      cast("Nocturnal Hunger", mana: { black: 3 }, gift: true, targets: [bear])

      expect(p1.life).to eq(20)
    end
  end

  describe "Parting Gust" do
    it "exiles the creature for good when the gift was promised" do
      cast("Parting Gust", mana: { white: 2 }, gift: true, targets: [bear])
      current_turn.end!

      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "returns it with a +1/+1 counter at the next end step without the gift" do
      cast("Parting Gust", mana: { white: 2 }, targets: [bear])
      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")

      current_turn.end!
      game.settle!
      returned = p2.permanents.find { _1.name == "Grizzly Bears" }

      expect(returned.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    end
  end

  describe "Peerless Recycling" do
    let(:land) { Card("Forest", owner: p1) }
    let(:other) { Card("Grizzly Bears", owner: p1) }

    before { [land, other].each { p1.graveyard.add(_1) } }

    it "returns a permanent card to your hand" do
      cast("Peerless Recycling", mana: { green: 2 }, targets: [land])

      expect(p1.hand.cards).to include(land)
    end

    it "returns two when the gift was promised" do
      cast("Peerless Recycling", mana: { green: 2 }, gift: true, targets: [land, other])

      expect(p1.hand.cards).to include(land, other)
    end
  end

  describe "Sazacap's Brew" do
    it "makes you discard a card and target player draw two" do
      discarded = p1.hand.first
      before = p1.hand.count
      cast("Sazacap's Brew", mana: { red: 2 }, targets: [p1]) { _1.pay_discard(discarded) }

      expect(p1.graveyard.cards).to include(discarded)
      expect(p1.hand.count).to eq(before - 1 + 2)
    end

    it "gives a creature +2/+0 when the gift was promised" do
      mine
      cast("Sazacap's Brew", mana: { red: 2 }, gift: true, targets: [p1, mine]) { _1.pay_discard(p1.hand.first) }

      expect(mine.power).to eq(4)
    end
  end

  describe "Scrapshooter" do
    let!(:bow) { ResolvePermanent("Short Bow", owner: p2) }

    it "has reach and 4/4 stats" do
      creature = ResolvePermanent("Scrapshooter", owner: p1)

      expect(creature.power).to eq(4)
      expect(creature.keywords).to include(Magic::Cards::Keywords::REACH)
    end

    it "doesn't destroy anything without the gift" do
      cast("Scrapshooter", mana: { green: 3 })

      expect(bow.zone).to be_battlefield
    end

    it "destroys an artifact or enchantment an opponent controls when the gift was promised" do
      cast("Scrapshooter", mana: { green: 3 }, gift: true)

      expect(p2.graveyard.cards.map(&:name)).to include("Short Bow")
    end
  end

  describe "Starfall Invocation" do
    it "destroys all creatures" do
      mine
      cast("Starfall Invocation", mana: { white: 5 })

      expect(game.battlefield.creatures).to be_empty
    end

    # The gift paths are in spec/cards/starfall_invocation_spec.rb: it promises the gift through Costs::Gift.
  end

  describe "Valley Rally" do
    it "gives your creatures +2/+0" do
      mine
      cast("Valley Rally", mana: { red: 3 })

      expect(mine.power).to eq(4)
      expect(bear.power).to eq(2)
    end

    it "gives a creature first strike when the gift was promised" do
      mine
      cast("Valley Rally", mana: { red: 3 }, gift: true, targets: [mine])

      expect(mine.keywords).to include(Magic::Cards::Keywords::FIRST_STRIKE)
    end
  end

  describe "Wear Down" do
    let!(:bow) { ResolvePermanent("Short Bow", owner: p2) }
    let!(:sword) { ResolvePermanent("Sword Of Vengeance", owner: p2) }

    it "destroys an artifact or enchantment" do
      cast("Wear Down", mana: { green: 2 }, targets: [bow])

      expect(bow.zone).to be_nil
      expect(sword.zone).to be_battlefield
    end

    it "destroys two when the gift was promised" do
      cast("Wear Down", mana: { green: 2 }, gift: true, targets: [bow, sword])

      expect(p2.graveyard.cards.map(&:name)).to include("Short Bow", "Sword of Vengeance")
    end
  end

  describe "Wildfire Howl" do
    it "deals 2 damage to each creature" do
      mine
      cast("Wildfire Howl", mana: { red: 3 })

      expect(game.battlefield.creatures).to be_empty
    end

    it "also deals 1 damage to any target when the gift was promised" do
      cast("Wildfire Howl", mana: { red: 3 }, gift: true, targets: [p2])

      expect(p2.life).to eq(19)
    end
  end

  describe "Jolly Gerbils" do
    it "draws a card whenever you give a gift" do
      ResolvePermanent("Jolly Gerbils", owner: p1)
      before = p1.hand.count
      cast("Dawn's Truce", mana: { white: 2 }, gift: true)

      expect(p1.hand.count).to eq(before + 1)
    end

    it "doesn't draw when no gift is given" do
      ResolvePermanent("Jolly Gerbils", owner: p1)
      before = p1.hand.count
      cast("Dawn's Truce", mana: { white: 2 })

      expect(p1.hand.count).to eq(before)
    end
  end
end
