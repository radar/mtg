# frozen_string_literal: true

require "spec_helper"

# Bloomburrow's valiant creatures: each triggers the first time each turn a spell or ability
# its controller controls targets it. Titanic Growth is the targeting spell throughout.
RSpec.describe "Valiant creatures" do
  include_context "two player game"

  def target_with_growth(creature, player: p1)
    player.add_mana(green: 2)
    player.cast(card: Card("Titanic Growth", owner: player)) do
      _1.auto_pay_mana
      _1.targeting(creature)
    end
    game.settle!
    yield if block_given?
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  describe "Emberheart Challenger" do
    let!(:creature) { ResolvePermanent("Emberheart Challenger", owner: p1) }

    it "has haste and prowess" do
      expect(creature.keywords).to include(Magic::Cards::Keywords::HASTE, Magic::Cards::Keywords::PROWESS)
    end

    it "exiles the top card of the library and lets you play it this turn" do
      top = p1.library.first
      target_with_growth(creature)

      expect(game.exile.cards).to include(top)
      expect(game.play_permissions.permits?(top, p1)).to be true
    end
  end

  describe "Flowerfoot Swordmaster" do
    let!(:swordmaster) { ResolvePermanent("Flowerfoot Swordmaster", owner: p1) }
    let!(:other_mouse) { ResolvePermanent("Heartfire Hero", owner: p1) }
    let!(:rat) { ResolvePermanent("Brightblade Stoat", owner: p1) }

    it "gives Mice you control +1/+0" do
      target_with_growth(swordmaster)

      expect(other_mouse.power).to eq(2)
      expect(swordmaster.power).to eq(1 + 4 + 1)
      expect(rat.power).to eq(2)
    end
  end

  describe "Mouse Trapper" do
    let!(:trapper) { ResolvePermanent("Mouse Trapper", owner: p1) }
    let!(:victim) { ResolvePermanent("Brightblade Stoat", owner: p2) }

    it "taps target creature an opponent controls" do
      target_with_growth(trapper)

      expect(victim).to be_tapped
    end
  end

  describe "Nettle Guard" do
    let!(:guard) { ResolvePermanent("Nettle Guard", owner: p1) }

    it "gets +0/+2 when targeted" do
      target_with_growth(guard)

      expect(guard.toughness).to eq(1 + 4 + 2)
    end

    it "destroys an artifact by sacrificing itself" do
      sword = ResolvePermanent("Short Bow", owner: p2)
      p1.add_mana(white: 1)
      p1.activate_ability(ability: guard.activated_abilities.first) do |action|
        action.pay_mana(generic: { white: 1 })
        action.targeting(sword)
      end
      game.stack.resolve!
      game.settle!

      expect(game.battlefield.cards).not_to include(sword)
      expect(game.battlefield.cards).not_to include(guard)
    end
  end

  describe "Seedglaive Mentor" do
    let!(:mentor) { ResolvePermanent("Seedglaive Mentor", owner: p1) }

    it "gets a +1/+1 counter when targeted" do
      target_with_growth(mentor)

      expect(mentor.power).to eq(3 + 4 + 1)
    end

    it "also triggers when a triggered ability you control targets it" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Pileated Provisioner", owner: p1)
      game.resolve_choice!(target: mentor)
      game.settle!
      game.tick!

      # +1/+1 counter from the Provisioner, and another from valiant.
      expect(mentor.power).to eq(3 + 1 + 1)
    end

    it "doesn't trigger when an opponent's ability targets it" do
      ResolvePermanent("Pileated Provisioner", owner: p2)
      game.resolve_choice!(target: ResolvePermanent("Grizzly Bears", owner: p2)) if game.choices.any?
      game.settle!
      game.tick!

      expect(mentor.power).to eq(3)
    end

    it "triggers only the first time each turn" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      2.times do
        ResolvePermanent("Pileated Provisioner", owner: p1)
        game.resolve_choice!(target: mentor)
        game.settle!
      end
      game.tick!

      expect(mentor.power).to eq(3 + 2 + 1)
    end
  end

  describe "Veteran Guardmouse" do
    let!(:guardmouse) { ResolvePermanent("Veteran Guardmouse", owner: p1) }

    it "gets +1/+0 and first strike, then scries 1" do
      target_with_growth(guardmouse) { game.skip_choice! }

      expect(guardmouse.power).to eq(3 + 4 + 1)
      expect(guardmouse.keywords).to include(Magic::Cards::Keywords::FIRST_STRIKE)
    end
  end

  describe "Whiskerquill Scribe" do
    let!(:scribe) { ResolvePermanent("Whiskerquill Scribe", owner: p1) }

    it "may discard a card to draw a card" do
      discarded = p1.hand.first
      target_with_growth(scribe)
      hand_size = p1.hand.count
      game.resolve_choice!
      game.resolve_choice!(card: discarded)

      expect(p1.graveyard.cards).to include(discarded)
      expect(p1.hand.count).to eq(hand_size)
    end

    it "does nothing when declined" do
      target_with_growth(scribe)
      hand_size = p1.hand.count
      game.skip_choice!

      expect(p1.hand.count).to eq(hand_size)
    end
  end

  describe "Whiskervale Forerunner" do
    let!(:forerunner) { ResolvePermanent("Whiskervale Forerunner", owner: p1) }
    let!(:creature_card) { Card("Daggerfang Duo", owner: p1) }

    before { p1.library.add(creature_card) }

    it "puts the creature onto the battlefield on your turn" do
      go_to_main_phase!
      p1.library.add(creature_card)
      target_with_growth(forerunner)
      game.resolve_choice!(target: creature_card)

      expect(game.battlefield.cards.map(&:name)).to include("Daggerfang Duo")
    end

    it "puts the creature into your hand on an opponent's turn" do
      go_to_main_phase_for!(p2)
      p1.library.add(creature_card)
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) do
        _1.auto_pay_mana
        _1.targeting(forerunner)
      end
      game.stack.resolve!
      game.settle!
      game.resolve_choice!(target: creature_card)

      expect(p1.hand.cards).to include(creature_card)
    end
  end
end
