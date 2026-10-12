# frozen_string_literal: true

require "spec_helper"

# Bloomburrow cards that cast or return things from graveyards and exile.
RSpec.describe "Bloomburrow graveyard and exile cards" do
  include_context "two player game"

  before { go_to_main_phase! }

  def bear(owner: p1) = ResolvePermanent("Grizzly Bears", owner: owner)

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def cast(name, mana:, targets: [], gift: false)
    p1.add_mana(**mana)
    p1.cast(card: Card(name, owner: p1)) do |action|
      action.promise_gift if gift
      action.targeting(*targets) if targets.any?
      action.auto_pay_mana
    end
    game.settle!
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  describe "Coiling Rebirth" do
    let(:dead) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }

    it "returns a creature card to the battlefield" do
      cast("Coiling Rebirth", mana: { black: 5 }, targets: [dead])

      expect(p1.creatures.map(&:name)).to eq(["Grizzly Bears"])
    end

    it "also creates a 1/1 token copy when the gift was promised" do
      cast("Coiling Rebirth", mana: { black: 5 }, targets: [dead], gift: true)
      copy = p1.creatures.find(&:token?)

      expect(p1.creatures.count).to eq(2)
      expect([copy.power, copy.toughness]).to eq([1, 1])
    end

    it "makes no copy of a legendary creature" do
      legend = Card("Gev, Scaled Scorch", owner: p1).tap { p1.graveyard.add(_1) }
      cast("Coiling Rebirth", mana: { black: 5 }, targets: [legend], gift: true)

      expect(p1.creatures.count).to eq(1)
    end
  end

  describe "Cruelclaw's Heist" do
    it "exiles a nonland card from the opponent's hand" do
      card = Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) }
      cast("Cruelclaw's Heist", mana: { black: 2 }, targets: [p2])
      game.resolve_choice!(card: card)

      expect(game.exile.cards).to include(card)
      expect(game.play_permissions.permits?(card, p1)).to be false
    end

    it "lets you cast it with any mana for as long as it remains exiled when the gift was promised" do
      card = Card("Grizzly Bears", owner: p2).tap { p2.hand.add(_1) }
      cast("Cruelclaw's Heist", mana: { black: 2 }, targets: [p2], gift: true)
      game.resolve_choice!(card: card)
      game.next_turn
      game.next_turn

      expect(game.play_permissions.permits?(card, p1)).to be true
      expect(game.play_permissions.any_mana?(card, p1)).to be true
    end
  end

  describe "Daring Waverider" do
    it "casts an instant or sorcery with mana value 4 or less from your graveyard for free, then exiles it" do
      target = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Titanic Growth", owner: p1).tap { p1.graveyard.add(_1) }
      ResolvePermanent("Daring Waverider", owner: p1)
      game.resolve_choice!
      game.resolve_choice!(target: target) if game.choices.any?
      game.stack.resolve!
      game.tick!

      expect(target.power).to eq(6)
      expect(game.exile.cards).to include(spell)
    end
  end

  describe "Wishing Well" do
    it "casts a spell with mana value equal to its coin counters from your graveyard for free" do
      well = ResolvePermanent("Wishing Well", owner: p1)
      spell = Card("Pawpatch Formation", owner: p1)
      graveyard_spell = Card("Titanic Growth", owner: p1).tap { p1.graveyard.add(_1) }
      target = bear
      p1.activate_ability(ability: well.activated_abilities.first)
      game.stack.resolve!
      expect(well.counters.of_type(Magic::Counters["coin"]).count).to eq(1)
      expect(spell).not_to be_nil
      expect(graveyard_spell.mana_value).to eq(2)

      well.untap!
      p1.activate_ability(ability: well.activated_abilities.first)
      game.stack.resolve!
      game.resolve_choice!(target: target) if game.choices.any?
      game.stack.resolve!
      game.tick!

      expect(target.power).to eq(6)
    end
  end

  describe "Driftgloom Coyote" do
    it "exiles an opposing creature until it leaves, growing if the creature had power 2 or less" do
      victim = bear(owner: p2)
      coyote = ResolvePermanent("Driftgloom Coyote", owner: p1)
      game.resolve_choice!(target: victim) if game.choices.any?
      game.tick!

      expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
      expect(coyote.power).to eq(4)

      coyote.destroy!
      game.settle!
      expect(p2.creatures.map(&:name)).to include("Grizzly Bears")
    end
  end

  describe "Clement, the Worrywort" do
    it "returns a creature with lesser mana value to hand when a creature enters" do
      cheap = ResolvePermanent("Heartfire Hero", owner: p1)
      ResolvePermanent("Clement, The Worrywort", owner: p1)
      game.resolve_choice!(target: cheap) if game.choices.any?

      expect(p1.hand.cards.map(&:name)).to include("Heartfire Hero")
    end

    it "gives Frogs a mana ability for creature spells" do
      clement = ResolvePermanent("Clement, The Worrywort", owner: p1)
      game.tick!
      ability = clement.activated_abilities.find { _1.is_a?(Class) ? _1.name.to_s.include?("ManaAbility") : _1.class.name.include?("ManaAbility") }

      expect(ability).not_to be_nil
    end
  end

  describe "Bonecache Overseer" do
    let!(:overseer) { ResolvePermanent("Bonecache Overseer", owner: p1) }

    it "can't draw without three cards leaving the graveyard or a Food sacrifice" do
      expect(overseer.activated_abilities.first.requirements_met?).to be false
    end

    it "can draw after sacrificing a Food" do
      Magic::Tokens::Food.new(game: game, owner: p1).resolve!.sacrifice!
      expect(overseer.activated_abilities.first.requirements_met?).to be true

      before = p1.hand.count
      p1.activate_ability(ability: overseer.activated_abilities.first)
      game.stack.resolve!

      expect(p1.hand.count).to eq(before + 1)
      expect(p1.life).to eq(19)
    end

    it "can draw after three cards left the graveyard" do
      cards = 3.times.map { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
      cards.each(&:exile!)

      expect(overseer.activated_abilities.first.requirements_met?).to be true
    end
  end
end
