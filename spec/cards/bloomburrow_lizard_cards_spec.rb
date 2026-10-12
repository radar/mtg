# frozen_string_literal: true

require "spec_helper"

# Bloomburrow's Lizards and the other cards that punish an opponent who lost life this turn.
RSpec.describe "Bloomburrow Lizards" do
  include_context "two player game"

  before { go_to_main_phase! }

  def opponent_loses_life = p2.lose_life(1).tap { game.settle! }

  describe "Cindering Cutthroat" do
    it "enters with a +1/+1 counter if an opponent lost life this turn" do
      opponent_loses_life
      cutthroat = ResolvePermanent("Cindering Cutthroat", owner: p1)

      expect(cutthroat.power).to eq(4)
    end

    it "enters without one otherwise" do
      cutthroat = ResolvePermanent("Cindering Cutthroat", owner: p1)

      expect(cutthroat.power).to eq(3)
    end

    it "gains menace for {1}{B/R}" do
      cutthroat = ResolvePermanent("Cindering Cutthroat", owner: p1)
      p1.add_mana(red: 2)
      p1.activate_ability(ability: cutthroat.activated_abilities.first) { _1.pay_mana(generic: { red: 1 }, red: 1) }
      game.stack.resolve!
      game.tick!

      expect(cutthroat.keywords).to include(Magic::Cards::Keywords::MENACE)
    end
  end

  describe "Frilled Sparkshooter" do
    it "enters with a +1/+1 counter if an opponent lost life this turn" do
      opponent_loses_life

      expect(ResolvePermanent("Frilled Sparkshooter", owner: p1).power).to eq(4)
    end
  end

  describe "Flamecache Gecko" do
    it "adds {B}{R} when it enters if an opponent lost life this turn" do
      opponent_loses_life
      ResolvePermanent("Flamecache Gecko", owner: p1)

      expect(p1.mana_pool[:black]).to eq(1)
      expect(p1.mana_pool[:red]).to eq(1)
    end

    it "adds nothing otherwise" do
      ResolvePermanent("Flamecache Gecko", owner: p1)

      expect(p1.mana_pool[:red]).to eq(0)
    end

    it "loots for {1}{R} and a discard" do
      gecko = ResolvePermanent("Flamecache Gecko", owner: p1)
      p1.add_mana(red: 2)
      discarded = p1.hand.first
      before = p1.hand.count
      p1.activate_ability(ability: gecko.activated_abilities.first) do |action|
        action.pay_mana(generic: { red: 1 }, red: 1)
        action.pay_discard(discarded)
      end
      game.stack.resolve!

      expect(p1.graveyard.cards).to include(discarded)
      expect(p1.hand.count).to eq(before)
    end
  end

  describe "Fireglass Mentor" do
    it "exiles two cards at your second main phase after an opponent lost life and lets you play one" do
      ResolvePermanent("Fireglass Mentor", owner: p1)
      opponent_loses_life
      top_two = p1.library.first(2)
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.end_of_combat!
      current_turn.second_main!
      game.settle!
      game.resolve_choice!(target: top_two.first)

      expect(game.exile.cards).to include(*top_two)
      expect(game.play_permissions.permits?(top_two.first, p1)).to be true
      expect(game.play_permissions.permits?(top_two.last, p1)).to be false
    end
  end

  describe "Gev, Scaled Scorch" do
    it "puts an extra counter on other creatures entering per opponent who lost life" do
      ResolvePermanent("Gev, Scaled Scorch", owner: p1)
      opponent_loses_life
      bear = ResolvePermanent("Grizzly Bears", owner: p1)

      expect(bear.power).to eq(3)
    end

    it "deals 1 damage to an opponent when you cast a Lizard spell" do
      ResolvePermanent("Gev, Scaled Scorch", owner: p1)
      p1.add_mana(red: 2, black: 1)
      p1.cast(card: Card("Cindering Cutthroat", owner: p1)) { _1.auto_pay_mana }
      game.settle!

      expect(p2.life).to eq(19)
    end

    it "has ward - pay 2 life" do
      expect(Magic::Cards::GevScaledScorch.const_get(:WARD_TRIGGER)).to be_a(Class)
    end
  end

  describe "Hired Claw" do
    let!(:claw) { ResolvePermanent("Hired Claw", owner: p1) }

    it "deals 1 damage to an opponent when you attack with a Lizard" do
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(claw, target: p2)
      current_turn.attackers_declared!
      game.settle!

      expect(p2.life).to eq(19)
    end

    it "grows for {1}{R}, only if an opponent lost life and once each turn" do
      ability = claw.activated_abilities.first
      expect(ability.requirements_met?).to be false

      opponent_loses_life
      expect(ability.requirements_met?).to be true
      p1.add_mana(red: 2)
      p1.activate_ability(ability: ability) { _1.pay_mana(generic: { red: 1 }, red: 1) }
      game.stack.resolve!
      game.tick!

      expect(claw.power).to eq(2)
    end
  end

  describe "Iridescent Vinelasher" do
    it "deals 1 damage to an opponent on landfall" do
      ResolvePermanent("Iridescent Vinelasher", owner: p1)
      p1.play_land(land: Card("Forest", owner: p1))
      game.settle!

      expect(p2.life).to eq(19)
    end
  end

  describe "Kindlespark Duo" do
    let!(:duo) { ResolvePermanent("Kindlespark Duo", owner: p1) }

    it "pings an opponent for {T}" do
      p1.activate_ability(ability: duo.activated_abilities.first)
      game.stack.resolve!

      expect(p2.life).to eq(19)
      expect(duo).to be_tapped
    end

    it "untaps when you cast a noncreature spell" do
      duo.tap!
      target = ResolvePermanent("Grizzly Bears", owner: p1)
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(target) }
      game.settle!

      expect(duo).not_to be_tapped
    end
  end

  describe "Hearthborn Battler" do
    it "deals 2 damage to an opponent when a player casts their second spell each turn" do
      ResolvePermanent("Hearthborn Battler", owner: p1)
      target = ResolvePermanent("Grizzly Bears", owner: p1)
      2.times do
        p1.add_mana(green: 2)
        p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(target) }
        game.settle!
        game.stack.resolve!
      end

      expect(p2.life).to eq(18)
    end
  end

  describe "Steampath Charger" do
    it "deals 1 damage to target player when it dies" do
      charger = ResolvePermanent("Steampath Charger", owner: p1)
      charger.destroy!
      game.settle!
      game.resolve_choice!(target: p2)

      expect(p2.life).to eq(19)
    end
  end

  describe "Thieving Otter" do
    it "draws a card when it deals damage to an opponent" do
      otter = ResolvePermanent("Thieving Otter", owner: p1)
      before = p1.hand.count
      otter.trigger_effect(:deal_damage, target: p2, damage: 2)
      game.settle!

      expect(p1.hand.count).to eq(before + 1)
    end
  end
end
