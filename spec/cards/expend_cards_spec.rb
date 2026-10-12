# frozen_string_literal: true

require "spec_helper"

# Bloomburrow's expend creatures: they trigger as you spend your fourth total mana in a turn.
RSpec.describe "Expend creatures" do
  include_context "two player game"

  let!(:target) { ResolvePermanent("Brightblade Stoat", owner: p1) }

  def spend_mana(count)
    (count / 2).times do
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) do
        _1.auto_pay_mana
        _1.targeting(target)
      end
      game.settle!
      yield if block_given?
      game.stack.resolve!
      game.settle!
    end
    game.tick!
  end

  it "records mana spent through the turn" do
    spend_mana(2)

    expect(game.current_turn.mana_spent_by_player(p1)).to eq(2)
    expect(game.current_turn.mana_spent_by_player(p2)).to eq(0)
  end

  describe "Bakersbane Duo" do
    it "creates a Food when it enters" do
      ResolvePermanent("Bakersbane Duo", owner: p1)

      expect(p1.permanents.map(&:name)).to include("Food")
    end

    it "gets +1/+1 on the fourth mana spent only" do
      duo = ResolvePermanent("Bakersbane Duo", owner: p1)
      spend_mana(2)
      expect(duo.power).to eq(2)

      spend_mana(2)
      expect(duo.power).to eq(3)
      expect(duo.toughness).to eq(3)
    end
  end

  describe "Bark-Knuckle Boxer" do
    it "gains indestructible when you expend 4" do
      boxer = ResolvePermanent("Bark-Knuckle Boxer", owner: p1)
      spend_mana(4)

      expect(boxer.keywords).to include(Magic::Cards::Keywords::INDESTRUCTIBLE)
    end
  end

  describe "Brambleguard Veteran" do
    it "gives Raccoons +1/+1 and vigilance" do
      veteran = ResolvePermanent("Brambleguard Veteran", owner: p1)
      other = ResolvePermanent("Bark-Knuckle Boxer", owner: p1)
      spend_mana(4)

      expect(veteran.power).to eq(4)
      expect(other.power).to eq(4)
      expect(other.keywords).to include(Magic::Cards::Keywords::VIGILANCE)
      expect(target.power).to eq(2 + 8)
    end
  end

  describe "Byway Barterer" do
    it "may discard your hand to draw two cards" do
      ResolvePermanent("Byway Barterer", owner: p1)
      spend_mana(4)
      game.resolve_choice!

      expect(p1.hand.count).to eq(2)
    end
  end

  describe "Junkblade Bruiser" do
    it "gets +2/+1" do
      bruiser = ResolvePermanent("Junkblade Bruiser", owner: p1)
      spend_mana(4)

      expect(bruiser.power).to eq(6)
      expect(bruiser.toughness).to eq(6)
    end
  end

  describe "Roughshod Duo" do
    it "pumps a target creature and gives it trample" do
      ResolvePermanent("Roughshod Duo", owner: p1)
      spend_mana(4) { game.resolve_choice!(target: target) if game.choices.any? }

      expect(target.keywords).to include(Magic::Cards::Keywords::TRAMPLE)
    end
  end

  describe "Teapot Slinger" do
    it "deals 2 damage to each opponent" do
      ResolvePermanent("Teapot Slinger", owner: p1)
      spend_mana(4)

      expect(p2.life).to eq(18)
    end
  end

  describe "Wandertale Mentor" do
    it "gets a +1/+1 counter" do
      mentor = ResolvePermanent("Wandertale Mentor", owner: p1)
      spend_mana(4)

      expect(mentor.power).to eq(3)
    end

    it "taps for red or green" do
      mentor = ResolvePermanent("Wandertale Mentor", owner: p1)
      p1.activate_ability(ability: mentor.activated_abilities.first) { _1.choose(:red) }

      expect(p1.mana_pool[:red]).to eq(1)
    end
  end
end
