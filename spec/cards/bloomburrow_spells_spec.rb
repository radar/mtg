# frozen_string_literal: true

require "spec_helper"

# Bloomburrow instants and sorceries without a gift.
RSpec.describe "Bloomburrow spells" do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def cast(name, mana:, targets: [], x: nil, player: p1, payment: nil)
    player.add_mana(**mana)
    player.cast(card: Card(name, owner: player), value_for_x: x) do |action|
      action.targeting(*targets) if targets.any?
      payment ? action.pay_mana(payment) : action.auto_pay_mana
      yield action if block_given?
    end
    game.settle!
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  it "Rabid Bite has your creature deal damage equal to its power" do
    big = ResolvePermanent("Nettle Guard", owner: p1)
    cast("Rabid Bite", mana: { green: 2 }, targets: [big, theirs])

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "Rabid Gnaw gives +1/+0 first" do
    cast("Rabid Gnaw", mana: { red: 2 }, targets: [mine, theirs])

    expect(mine.power).to eq(3)
    expect(theirs.zone).to be_nil
  end

  describe "Polliwallop" do
    it "deals twice the creature's power" do
      cast("Polliwallop", mana: { green: 4 }, targets: [mine, theirs])

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "costs {1} less for each Frog you control" do
      2.times { ResolvePermanent("Valley Mightcaller", owner: p1) }
      cast("Polliwallop", mana: { green: 2 }, targets: [mine, theirs])

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end
  end

  describe "Might Of The Meek" do
    it "gives trample and draws a card" do
      before = p1.hand.count
      cast("Might Of The Meek", mana: { red: 1 }, targets: [mine])

      expect(mine.keywords).to include(Magic::Cards::Keywords::TRAMPLE)
      expect(mine.power).to eq(2)
      expect(p1.hand.count).to eq(before + 1)
    end

    it "gives +1/+0 if you control a Mouse" do
      ResolvePermanent("Heartfire Hero", owner: p1)
      cast("Might Of The Meek", mana: { red: 1 }, targets: [mine])

      expect(mine.power).to eq(3)
    end
  end

  it "Rabbit Response gives creatures +2/+1 and scries with a Rabbit" do
    ResolvePermanent("Seasoned Warrenguard", owner: p1)
    cast("Rabbit Response", mana: { white: 4 })

    expect(game.choices.first).to be_a(Magic::Choice::Scry)
  end

  describe "Repel Calamity" do
    it "destroys a creature with power or toughness 4 or greater" do
      big = ResolvePermanent("Quaketusk Boar", owner: p2)
      cast("Repel Calamity", mana: { white: 2 }, targets: [big])

      expect(p2.graveyard.cards.map(&:name)).to include("Quaketusk Boar")
    end

    it "can't target a small creature" do
      expect { cast("Repel Calamity", mana: { white: 2 }, targets: [theirs]) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end
  end

  describe "Sonar Strike" do
    it "deals 4 damage to a tapped creature and gains 3 life with a Bat" do
      ResolvePermanent("Essence Channeler", owner: p1)
      theirs.tap!
      cast("Sonar Strike", mana: { white: 2 }, targets: [theirs])

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(p1.life).to eq(23)
    end

    it "can't target an untapped, non-combat creature" do
      expect { cast("Sonar Strike", mana: { white: 2 }, targets: [theirs]) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
    end
  end

  it "Take Out the Trash deals 3 damage and loots with a Raccoon" do
    ResolvePermanent("Byway Barterer", owner: p1)
    discarded = p1.hand.first
    cast("Take Out The Trash", mana: { red: 2 }, targets: [theirs])
    game.resolve_choice!
    game.resolve_choice!(card: discarded)

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(p1.graveyard.cards).to include(discarded)
  end

  it "Conduct Electricity deals 6 to a creature and 2 to a token" do
    token = Magic::Tokens::Fish.new(game: game, owner: p2).resolve!
    big = ResolvePermanent("Quaketusk Boar", owner: p2)
    cast("Conduct Electricity", mana: { red: 5 }, targets: [big, token])

    expect(p2.graveyard.cards.map(&:name)).to include("Quaketusk Boar")
    expect(token.zone).to be_nil
  end

  it "Calamitous Tide bounces two creatures then draws two and discards one" do
    other = ResolvePermanent("Grizzly Bears", owner: p2)
    before = p1.hand.count
    cast("Calamitous Tide", mana: { blue: 6 }, targets: [theirs, other])
    game.resolve_choice!(card: p1.hand.first)

    expect(p2.hand.cards.count { _1.name == "Grizzly Bears" }).to eq(2)
    expect(p1.hand.count).to eq(before + 1)
  end

  describe "Psychic Whorl" do
    it "makes the opponent discard two cards" do
      before = p2.hand.count
      cast("Psychic Whorl", mana: { black: 3 }, targets: [p2])
      2.times { game.resolve_choice!(card: p2.hand.first) }

      expect(p2.hand.count).to eq(before - 2)
    end

    it "surveils 2 with a Rat" do
      ResolvePermanent("Persistent Marshstalker", owner: p1) if Magic::Cards.const_defined?(:PersistentMarshstalker)
      rat = ResolvePermanent("Thornplate Intimidator", owner: p1)
      game.skip_choice!
      cast("Psychic Whorl", mana: { black: 3 }, targets: [p2])
      2.times { game.resolve_choice!(card: p2.hand.first) }

      expect(rat.type?("Rat")).to be true
      expect(game.choices.first).to be_a(Magic::Choice::Surveil)
    end
  end

  it "Mind Spring draws X cards" do
    before = p1.hand.count
    cast("Mind Spring", mana: { blue: 5 }, x: 3, payment: { x: { blue: 3 }, blue: 2 })

    expect(p1.hand.count).to eq(before + 3)
  end

  describe "Dazzling Denial" do
    def p2_casts_growth
      go_to_main_phase_for!(p2)
      p2.add_mana(green: 2)
      p2.cast(card: Card("Titanic Growth", owner: p2)) { _1.auto_pay_mana; _1.targeting(theirs) }
      game.stack.spells.first
    end

    it "counters a spell unless its controller pays {2}" do
      spell = p2_casts_growth
      cast("Dazzling Denial", mana: { blue: 2 }, targets: [spell])
      game.skip_choice!

      expect(p2.graveyard.cards.map(&:name)).to include("Titanic Growth")
    end

    it "lets the spell resolve if its controller pays" do
      spell = p2_casts_growth
      p2.add_mana(green: 2)
      cast("Dazzling Denial", mana: { blue: 2 }, targets: [spell])
      game.resolve_choice!

      expect(p2.graveyard.cards.map(&:name)).not_to include("Titanic Growth")
    end
  end

  it "Splash Portal blinks a creature and draws if it is a Frog" do
    frog = ResolvePermanent("Valley Mightcaller", owner: p1)
    frog.add_counter("+1/+1")
    before = p1.hand.count
    cast("Splash Portal", mana: { blue: 1 }, targets: [frog])

    expect(p1.creatures.map(&:name)).to include("Valley Mightcaller")
    expect(p1.hand.count).to eq(before + 1)
  end

  describe "Early Winter" do
    it "exiles a creature" do
      cast("Early Winter", mana: { black: 5 }) do |action|
        action.choose_mode(Magic::Cards::EarlyWinter::ExileCreature) { _1.targeting(theirs) }
      end

      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
    end
  end

  describe "Dire Downdraft" do
    it "puts a creature on the top or bottom of its owner's library" do
      cast("Dire Downdraft", mana: { blue: 4 }, targets: [theirs])
      game.resolve_choice!(position: :top)

      expect(p2.library.first.name).to eq("Grizzly Bears")
    end

    it "costs {1} less targeting a tapped creature" do
      theirs.tap!
      cast("Dire Downdraft", mana: { blue: 3 }, targets: [theirs])
      game.resolve_choice!(position: :bottom)

      expect(p2.library.cards.last.name).to eq("Grizzly Bears")
    end
  end

  describe "Cache Grab" do
    it "mills four and returns a permanent card, making a Food with a Squirrel" do
      ResolvePermanent("Valley Rotcaller", owner: p1)
      cast("Cache Grab", mana: { green: 2 })
      game.resolve_choice!(target: p1.graveyard.cards.find(&:permanent?))
      game.settle!

      expect(p1.graveyard.count).to eq(4) # three milled cards left, plus the spell
      expect(p1.permanents.map(&:name)).to include("Food")
    end
  end

  describe "Stargaze" do
    it "puts X of 2X cards into your hand, the rest into the graveyard, and costs X life" do
      looked = p1.library.first(4)
      cast("Stargaze", mana: { black: 4 }, x: 2, payment: { x: { black: 2 }, black: 2 })
      game.resolve_choice!(cards: looked.first(2))

      expect(p1.hand.cards).to include(*looked.first(2))
      expect(p1.graveyard.cards).to include(*looked.last(2))
      expect(p1.life).to eq(18)
    end
  end
end
