# frozen_string_literal: true

require "spec_helper"

# The last Bloomburrow cards: tap-token engines, Seasons, and the other multi-part rares.
RSpec.describe "Bloomburrow finale" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def fish = Magic::Tokens::Fish.new(game: game, owner: p1).resolve!

  describe "Baylen, the Haymaker" do
    let!(:baylen) { ResolvePermanent("Baylen, The Haymaker", owner: p1) }

    it "taps two tokens for one mana of any color" do
      tokens = Array.new(2) { fish }
      p1.activate_ability(ability: baylen.activated_abilities[0]) do |action|
        action.pay_multi_tap(tokens)
        action.choose(:red)
      end

      expect(p1.mana_pool[:red]).to eq(1)
      expect(tokens).to all(be_tapped)
    end

    it "taps three tokens to draw a card" do
      tokens = Array.new(3) { fish }
      before = p1.hand.count
      p1.activate_ability(ability: baylen.activated_abilities[1]) { _1.pay_multi_tap(tokens) }
      game.stack.resolve!

      expect(p1.hand.count).to eq(before + 1)
    end

    it "taps four tokens for three +1/+1 counters and trample" do
      tokens = Array.new(4) { fish }
      p1.activate_ability(ability: baylen.activated_abilities[2]) { _1.pay_multi_tap(tokens) }
      game.stack.resolve!
      game.tick!

      expect(counters(baylen)).to eq(3)
      expect(baylen.keywords).to include(Magic::Cards::Keywords::TRAMPLE)
    end
  end

  describe "Heirloom Epic" do
    it "draws a card for {4}, {T} as a sorcery, with creatures tapped for mana" do
      epic = ResolvePermanent("Heirloom Epic", owner: p1)
      creatures = Array.new(2) { bear }
      p1.add_mana(colorless: 2)
      before = p1.hand.count
      p1.activate_ability(ability: epic.activated_abilities.first) do |action|
        creatures.each { action.convoke(_1) }
        action.pay_mana(generic: { colorless: 2 })
      end
      game.stack.resolve!

      expect(p1.hand.count).to eq(before + 1)
      expect(creatures).to all(be_tapped)
    end
  end

  describe "Azure Beastbinder" do
    let!(:binder) { ResolvePermanent("Azure Beastbinder", owner: p1) }

    it "can't be blocked by creatures with power 2 or greater" do
      expect(binder.can_be_blocked?(bear(owner: p2))).to be false
      expect(binder.can_be_blocked?(ResolvePermanent("Heartfire Hero", owner: p2))).to be true
    end

    it "makes a creature lose its abilities and become 2/2 until your next turn" do
      victim = ResolvePermanent("Quaketusk Boar", owner: p2)
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(binder, target: p2)
      current_turn.attackers_declared!
      game.settle!
      game.resolve_choice!(target: victim)
      game.tick!

      expect([victim.power, victim.toughness]).to eq([2, 2])
      expect(victim).to be_lost_all_abilities

      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
      game.tick!
      expect([victim.power, victim.toughness]).to eq([5, 5])
      expect(victim).not_to be_lost_all_abilities
    end
  end

  describe "Glarb, Calamity's Augur" do
    it "lets you play lands and cast spells with mana value 4 or more from the top of your library" do
      glarb = ResolvePermanent("Glarb, Calamity's Augur", owner: p1)
      static = glarb.static_abilities.first

      expect(static.permits_casting_from_top?(Card("Forest", owner: p1), p1)).to be true
      expect(static.permits_casting_from_top?(Card("Quaketusk Boar", owner: p1), p1)).to be true
      expect(static.permits_casting_from_top?(Card("Grizzly Bears", owner: p1), p1)).to be false
      expect(static.permits_casting_from_top?(Card("Forest", owner: p2), p2)).to be false
    end

    it "surveils 2 for {T}" do
      glarb = ResolvePermanent("Glarb, Calamity's Augur", owner: p1)
      p1.activate_ability(ability: glarb.activated_abilities.first)
      game.stack.resolve!

      expect(game.choices.first).to be_a(Magic::Choice::Surveil)
    end
  end

  describe "Eluge, the Shoreless Sea" do
    it "floods a land, which becomes an Island and counts toward Eluge" do
      forest = ResolvePermanent("Forest", owner: p1)
      ResolvePermanent("Island", owner: p1)
      eluge = ResolvePermanent("Eluge, The Shoreless Sea", owner: p1)
      game.resolve_choice!(target: forest) if game.choices.any?
      game.tick!

      expect(forest.type?("Island")).to be true
      expect(eluge.power).to eq(2)
    end
  end

  describe "Festival of Embers" do
    it "lets you cast an instant from your graveyard on your turn for 1 life, then exiles it" do
      ResolvePermanent("Festival of Embers", owner: p1)
      target = bear
      spell = Card("Titanic Growth", owner: p1).tap { p1.graveyard.add(_1) }
      p1.add_mana(green: 2)
      p1.cast(card: spell) { _1.auto_pay_mana; _1.targeting(target) }
      game.stack.resolve!
      game.tick!

      expect(target.power).to eq(6)
      expect(p1.life).to eq(19)
      expect(game.exile.cards).to include(spell)
    end

    it "exiles your cards that would go to your graveyard" do
      ResolvePermanent("Festival of Embers", owner: p1)
      bear.destroy!
      game.settle!

      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
      expect(p1.graveyard.cards).to be_empty
    end
  end

  describe "Osteomancer Adept" do
    it "lets you cast a creature from your graveyard by foraging, with a finality counter" do
      adept = ResolvePermanent("Osteomancer Adept", owner: p1)
      dead = Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
      food = Magic::Tokens::Food.new(game: game, owner: p1).resolve!
      p1.activate_ability(ability: adept.activated_abilities.first)
      game.stack.resolve!
      p1.add_mana(green: 2)
      p1.cast(card: dead) do |action|
        action.auto_pay_mana
        action.pay_forage(food)
      end
      game.stack.resolve!
      returned = p1.creatures.find { _1.name == "Grizzly Bears" }

      expect(returned.counters.of_type(Magic::Counters["finality"]).count).to eq(1)
    end
  end

  describe "the Seasons" do
    def cast_season(name, mana, modes)
      p1.add_mana(**mana)
      p1.cast(card: Card(name, owner: p1)) do |action|
        action.auto_pay_mana
        modes.each { |mode_class, target| action.choose_mode(mode_class) { |mode| mode.targeting(*target) if target } }
      end
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "allows repeating a mode up to the five-point budget, and no more" do
      season = Magic::Cards::SeasonOfWeaving
      p1.add_mana(blue: 6)
      action = p1.prepare_cast(card: Card("Season Of Weaving", owner: p1))
      5.times { action.choose_mode(season::DrawCard) }

      expect { action.choose_mode(season::DrawCard) }.to raise_error(Magic::Actions::Cast::InvalidModes)
    end

    it "Season of Weaving draws for each point spent" do
      season = Magic::Cards::SeasonOfWeaving
      before = p1.hand.count
      cast_season("Season Of Weaving", { blue: 6 }, [[season::DrawCard, nil]] * 3)

      expect(p1.hand.count).to eq(before + 3)
    end

    it "Season of Gathering grows a creature" do
      season = Magic::Cards::SeasonOfGathering
      target = bear
      cast_season("Season Of Gathering", { green: 6 }, [[season::GrowCreature, [target]], [season::GrowCreature, [target]]])

      expect(counters(target)).to eq(2)
    end

    it "Season of Loss makes everyone sacrifice a creature" do
      season = Magic::Cards::SeasonOfLoss
      bear
      bear(owner: p2)
      cast_season("Season Of Loss", { black: 5 }, [[season::Edict, nil]])

      expect(game.battlefield.creatures).to be_empty
    end

    it "Season of the Bold makes a tapped Treasure" do
      season = Magic::Cards::SeasonOfTheBold
      cast_season("Season Of The Bold", { red: 5 }, [[season::TappedTreasure, nil]])
      treasure = p1.permanents.find { _1.name == "Treasure" }

      expect(treasure).to be_tapped
    end

    it "Season of the Burrow makes Rabbits and exiles a permanent" do
      season = Magic::Cards::SeasonOfTheBurrow
      victim = bear(owner: p2)
      cast_season("Season Of The Burrow", { white: 5 }, [[season::MakeRabbit, nil], [season::ExileAndDraw, [victim]]])

      expect(p1.creatures.map(&:name)).to include("Rabbit")
      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
    end
  end

  describe "Portent of Calamity" do
    it "exiles one card per type, putting the rest in the graveyard and the exiled cards in hand" do
      cards = [Card("Forest", owner: p1), Card("Grizzly Bears", owner: p1), Card("Titanic Growth", owner: p1)]
      cards.reverse.each { p1.library.add(_1) }
      p1.add_mana(blue: 4)
      p1.cast(card: Card("Portent Of Calamity", owner: p1), value_for_x: 3) { _1.pay_mana(x: { blue: 3 }, blue: 1) }
      game.stack.resolve!
      game.settle!
      game.resolve_choice!(cards: [cards[0], cards[1]])

      expect(p1.hand.cards).to include(cards[0], cards[1])
      expect(p1.graveyard.cards).to include(cards[2])
    end
  end

  describe "Rottenmouth Viper" do
    it "costs {1} less for each permanent sacrificed" do
      fodder = Array.new(2) { ResolvePermanent("Short Bow", owner: p1) }
      p1.add_mana(black: 4)
      p1.cast(card: Card("Rottenmouth Viper", owner: p1)) do |action|
        action.pay_sacrifice_any(fodder)
        action.pay_mana(generic: { black: 3 }, black: 1)
      end
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Rottenmouth Viper")
      expect(game.battlefield.cards).not_to include(*fodder)
    end

    it "makes each opponent lose 4 life unless they sacrifice or discard when it enters" do
      ResolvePermanent("Rottenmouth Viper", owner: p1)
      game.skip_choice!

      expect(p2.life).to eq(16)
    end
  end
end
