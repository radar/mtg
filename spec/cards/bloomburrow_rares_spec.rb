# frozen_string_literal: true

require "spec_helper"

# Bloomburrow's larger creatures: cost reducers, static effects and enters-the-battlefield modes.
RSpec.describe "Bloomburrow bigger creatures" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  describe "Eddymurk Crab" do
    it "costs {1} less for each instant and sorcery in your graveyard" do
      2.times { p1.graveyard.add(Card("Titanic Growth", owner: p1)) }
      p1.add_mana(blue: 5)
      p1.cast(card: Card("Eddymurk Crab", owner: p1)) { _1.auto_pay_mana }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Eddymurk Crab")
    end

    it "enters tapped when it isn't your turn" do
      go_to_main_phase_for!(p2)

      expect(Card("Eddymurk Crab", owner: p1).enters_tapped?).to be true
      expect(Card("Eddymurk Crab", owner: p2).enters_tapped?).to be false
    end

    it "taps up to two target creatures" do
      first = bear(owner: p2)
      second = bear(owner: p2)
      ResolvePermanent("Eddymurk Crab", owner: p1)
      game.resolve_choice!(targets: [first, second])

      expect(first).to be_tapped
      expect(second).to be_tapped
    end
  end

  describe "Fecund Greenshell" do
    it "gives creatures +2/+2 with ten lands" do
      shell = ResolvePermanent("Fecund Greenshell", owner: p1)
      game.skip_choice! while game.choices.any?
      10.times { ResolvePermanent("Forest", owner: p1) }
      game.tick!

      expect(shell.power).to eq(6)
    end

    it "puts the top card into your hand when a creature with toughness greater than power enters" do
      top = Card("Titanic Growth", owner: p1)
      ResolvePermanent("Fecund Greenshell", owner: p1)
      game.skip_choice! while game.choices.any?
      p1.library.add(top)
      ResolvePermanent("Barkform Harvester", owner: p1)

      expect(p1.hand.cards).to include(top)
    end

    it "may put a land on top of the library onto the battlefield tapped" do
      land = Card("Forest", owner: p1)
      ResolvePermanent("Fecund Greenshell", owner: p1)
      p1.library.add(land)
      ResolvePermanent("Barkform Harvester", owner: p1)
      game.resolve_choice! while game.choices.any?

      expect(p1.permanents.select(&:land?).any?(&:tapped?)).to be true
    end
  end

  describe "Huskburster Swarm" do
    it "costs {1} less for each creature card in your graveyard and exile" do
      3.times { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }
      cost = p1.prepare_cast(card: Card("Huskburster Swarm", owner: p1)).mana_cost

      expect(cost.cost[:generic]).to eq(4)
    end
  end

  describe "Maha, Its Feathers Night" do
    it "sets opposing creatures' base toughness to 1" do
      ResolvePermanent("Maha, Its Feathers Night", owner: p1)
      theirs = bear(owner: p2)
      mine = bear
      game.tick!

      expect(theirs.toughness).to eq(1)
      expect(mine.toughness).to eq(2)
    end

    it "has ward - discard a card" do
      maha = ResolvePermanent("Maha, Its Feathers Night", owner: p1)
      go_to_main_phase_for!(p2)
      p2.add_mana(green: 2)
      p2.cast(card: Card("Titanic Growth", owner: p2)) { _1.auto_pay_mana; _1.targeting(maha) }
      game.settle!

      expect(game.choices.first).to be_a(Magic::Choice::Ward)
      game.resolve_choice!
      expect(p2.graveyard.cards.map(&:name)).to include("Titanic Growth")
    end
  end

  describe "Barkform Harvester" do
    it "puts a card from your graveyard on the bottom of your library for {2}" do
      harvester = ResolvePermanent("Barkform Harvester", owner: p1)
      card = Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
      p1.add_mana(colorless: 2)
      p1.activate_ability(ability: harvester.activated_abilities.first) do |action|
        action.pay_mana(generic: { colorless: 2 })
        action.targeting(card)
      end
      game.stack.resolve!

      expect(p1.library.cards.last).to eq(card)
    end
  end

  describe "Bonebind Orator" do
    it "returns another creature card from your graveyard from the graveyard" do
      orator = Card("Bonebind Orator", owner: p1).tap { p1.graveyard.add(_1) }
      other = Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) }
      p1.add_mana(black: 4)
      p1.activate_ability(ability: orator.graveyard_abilities.first) do |action|
        action.pay_mana(generic: { black: 3 }, black: 1)
        action.pay_self_exile
        action.targeting(other)
      end
      game.stack.resolve!

      expect(p1.hand.cards).to include(other)
      expect(game.exile.cards).to include(orator)
    end
  end

  describe "Beza, the Bounding Spring" do
    it "gets the benefits when an opponent is ahead" do
      2.times { ResolvePermanent("Forest", owner: p2) }
      2.times { bear(owner: p2) }
      p2.hand.add(Card("Forest", owner: p2))
      9.times { p2.hand.add(Card("Forest", owner: p2)) }
      p1.lose_life(2)
      ResolvePermanent("Beza, The Bounding Spring", owner: p1)
      game.settle!

      names = p1.permanents.map(&:name)
      expect(names).to include("Treasure")
      expect(names.count("Fish")).to eq(2)
      expect(p1.life).to eq(22)
    end

    it "does nothing when nobody is ahead" do
      ResolvePermanent("Beza, The Bounding Spring", owner: p1)

      expect(p1.permanents.map(&:name)).to eq(["Beza, the Bounding Spring"])
    end
  end

  describe "Sunspine Lynx" do
    it "stops life gain" do
      ResolvePermanent("Sunspine Lynx", owner: p1)
      p1.gain_life(3)
      game.settle!

      expect(p1.life).to eq(20)
    end

    it "deals damage for nonbasic lands when it enters" do
      ResolvePermanent("Fountainport", owner: p2)
      ResolvePermanent("Sunspine Lynx", owner: p1)
      game.settle!

      expect(p2.life).to eq(19)
    end
  end

  describe "Dour Port-Mage" do
    it "draws when another creature leaves without dying" do
      ResolvePermanent("Dour Port-Mage", owner: p1)
      leaver = bear
      before = p1.hand.count
      leaver.exile!
      game.settle!

      expect(p1.hand.count).to eq(before + 1)
    end

    it "bounces another creature for {1}{U}, {T}" do
      mage = ResolvePermanent("Dour Port-Mage", owner: p1)
      target = bear
      p1.add_mana(blue: 2)
      p1.activate_ability(ability: mage.activated_abilities.first) do |action|
        action.pay_mana(generic: { blue: 1 }, blue: 1)
        action.targeting(target)
      end
      game.stack.resolve!

      expect(p1.hand.cards.map(&:name)).to include("Grizzly Bears")
    end
  end

  describe "Long River Lurker" do
    it "makes a creature unblockable this turn" do
      target = bear
      ResolvePermanent("Long River Lurker", owner: p1)
      game.resolve_choice!(target: target) if game.choices.any?

      expect(target.can_be_blocked?(bear(owner: p2))).to be false
    end

    it "gives other Frogs ward {1}" do
      lurker = ResolvePermanent("Long River Lurker", owner: p1)
      game.resolve_choice!(target: lurker) if game.choices.any?
      frog = ResolvePermanent("Valley Mightcaller", owner: p1)
      p2.add_mana(green: 2)
      p2.cast(card: Card("Titanic Growth", owner: p2)) { _1.auto_pay_mana; _1.targeting(frog) }
      game.settle!

      expect(game.choices.first).to be_a(Magic::Choice::Ward)
    end
  end

  describe "Lilysplash Mentor" do
    it "blinks another creature and gives it a +1/+1 counter" do
      mentor = ResolvePermanent("Lilysplash Mentor", owner: p1)
      target = bear
      p1.add_mana(green: 1, blue: 1, colorless: 1)
      p1.activate_ability(ability: mentor.activated_abilities.first) do |action|
        action.pay_mana(generic: { colorless: 1 }, green: 1, blue: 1)
        action.targeting(target)
      end
      game.stack.resolve!
      returned = p1.creatures.find { _1.name == "Grizzly Bears" }

      expect(counters(returned)).to eq(1)
    end
  end

  describe "Harnesser of Storms" do
    it "may exile the top card and play it, once each turn" do
      ResolvePermanent("Harnesser of Storms", owner: p1)
      target = bear
      top = p1.library.first
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(target) }
      game.settle!
      game.resolve_choice!

      expect(game.exile.cards).to include(top)
      expect(game.play_permissions.permits?(top, p1)).to be true
    end
  end

  describe "Jackdaw Savior" do
    it "returns a creature card with lesser mana value when it dies" do
      savior = ResolvePermanent("Jackdaw Savior", owner: p1)
      cheap = Card("Heartfire Hero", owner: p1).tap { p1.graveyard.add(_1) }
      savior.destroy!
      game.settle!
      game.resolve_choice!(target: cheap) if game.choices.any?

      expect(p1.creatures.map(&:name)).to eq(["Heartfire Hero"])
    end

    it "triggers for another flyer dying" do
      ResolvePermanent("Jackdaw Savior", owner: p1)
      flyer = ResolvePermanent("Pileated Provisioner", owner: p1)
      game.skip_choice! while game.choices.any?
      cheap = Card("Heartfire Hero", owner: p1).tap { p1.graveyard.add(_1) }
      flyer.destroy!
      game.settle!
      game.resolve_choice!(target: cheap) if game.choices.any?

      expect(p1.creatures.map(&:name)).to include("Heartfire Hero")
    end
  end

  describe "Wick's Patrol" do
    it "mills three and gives a creature -X/-X for the greatest mana value in your graveyard" do
      victim = ResolvePermanent("Quaketusk Boar", owner: p2)
      p1.graveyard.add(Card("Quaketusk Boar", owner: p1))
      ResolvePermanent("Wick's Patrol", owner: p1)
      game.resolve_choice!(target: victim) if game.choices.any?
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to include("Quaketusk Boar")
    end
  end

  describe "Byrke, Long Ear of the Law" do
    it "puts counters on up to two creatures and doubles them when they attack" do
      first = bear
      second = bear
      ResolvePermanent("Byrke, Long Ear Of The Law", owner: p1)
      game.resolve_choice!(targets: [first, second])
      expect(counters(first)).to eq(1)

      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(first, target: p2)
      current_turn.attackers_declared!
      game.settle!

      expect(counters(first)).to eq(2)
      expect(counters(second)).to eq(1)
    end
  end
end
