# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OrcishBowmasters do
  include_context "two player game"

  def armies = p1.creatures.by_type("Army")

  def resolve_damage_choice(target)
    game.resolve_choice!(target: target)
    game.settle!
  end

  describe "flash" do
    it "has flash and is a 1/1 Orc Archer" do
      card = Card("Orcish Bowmasters", owner: p1)
      expect(card.flash?).to eq(true)
      permanent = ResolvePermanent("Orcish Bowmasters", owner: p1)
      expect([permanent.power, permanent.toughness]).to eq([1, 1])
      expect(permanent.type?("Orc")).to eq(true)
      expect(permanent.type?("Archer")).to eq(true)
    end
  end

  describe "when it enters" do
    it "deals 1 damage to the chosen target, then amasses Orcs 1" do
      ResolvePermanent("Orcish Bowmasters", owner: p1)
      expect(game.choices.size).to eq(1)

      resolve_damage_choice(p2)

      expect(p2.life).to eq(19)
      expect(armies.size).to eq(1)
      expect(armies.first.type?("Orc")).to eq(true)
      expect(armies.first.power).to eq(1)
    end

    it "can target a creature" do
      other = ResolvePermanent("Goblin Arsonist", owner: p2)
      ResolvePermanent("Orcish Bowmasters", owner: p1)

      resolve_damage_choice(other)

      expect(other.damage).to eq(1)
      expect(p2.life).to eq(20)
    end
  end

  describe "when an opponent draws a card" do
    before do
      ResolvePermanent("Orcish Bowmasters", owner: p1)
      resolve_damage_choice(p2)
    end

    it "does not trigger on the first card drawn in their draw step" do
      go_to_main_phase_for!(p2)
      game.settle!

      expect(game.choices).to be_empty
      expect(p2.life).to eq(19)
    end

    it "triggers on a second card drawn in their draw step" do
      game.next_turn until current_turn.active_player == p2
      current_turn.untap!
      current_turn.upkeep!
      current_turn.draw!
      game.settle!
      expect(game.choices).to be_empty

      p2.draw!
      game.settle!

      expect(game.choices.size).to eq(1)
      resolve_damage_choice(p2)
      expect(p2.life).to eq(18)
      expect(armies.first.power).to eq(2)
    end

    it "triggers on a card drawn outside the draw step, even before the draw step" do
      game.next_turn until current_turn.active_player == p2
      current_turn.untap!
      current_turn.upkeep!
      p2.draw!
      game.settle!

      expect(game.choices.size).to eq(1)
      resolve_damage_choice(p2)
      expect(p2.life).to eq(18)
    end

    it "triggers on an opponent draw during your own turn" do
      go_to_main_phase!
      p2.draw!
      game.settle!

      expect(game.choices.size).to eq(1)
      resolve_damage_choice(p2)
      expect(p2.life).to eq(18)
    end

    it "does not trigger when its controller draws" do
      go_to_main_phase!
      game.settle!
      p1.draw!
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
