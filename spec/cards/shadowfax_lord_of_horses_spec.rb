# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShadowfaxLordOfHorses do
  include_context "two player game"

  let!(:shadowfax) { ResolvePermanent("Shadowfax Lord Of Horses", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) } }
  let(:angel) { Card("Serra Angel", owner: p1).tap { p1.hand.add(_1) } }
  let(:dragon) { Card("Shivan Dragon", owner: p1).tap { p1.hand.add(_1) } }

  def attack!(attacker: shadowfax, target: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: target)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a legendary 4/4 Horse" do
    expect([shadowfax.power, shadowfax.toughness]).to eq([4, 4])
    expect(shadowfax.type?("Horse")).to be(true)
  end

  describe "Horses you control have haste" do
    it "gives itself and other Horses haste" do
      horse = ResolvePermanent("Armored Warhorse", owner: p1, summoning_sick: true)
      game.tick!

      expect(horse).to have_keyword(:haste)
      expect(shadowfax).to have_keyword(:haste)
    end

    it "does not give non-Horses haste" do
      bear = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
      game.tick!

      expect(bear).not_to have_keyword(:haste)
    end

    it "does not give an opponent's Horses haste" do
      horse = ResolvePermanent("Armored Warhorse", owner: p2, summoning_sick: true)
      game.tick!

      expect(horse).not_to have_keyword(:haste)
    end
  end

  describe "attack trigger" do
    it "puts a creature card with lesser power onto the battlefield tapped and attacking" do
      bears
      attack!
      expect(game.choices.first.choices).to contain_exactly(bears)
      game.resolve_choice!(targets: [bears])

      permanent = p1.permanents.find { _1.card == bears }
      expect(permanent).to be_tapped
      expect(bears.zone).not_to be_hand
      expect(current_turn.combat.attacking?(permanent)).to be(true)
      expect(current_turn.combat.attack_for_attacker(permanent).target).to eq(p2)
    end

    it "does not offer cards with power equal to or greater than Shadowfax's" do
      bears
      angel
      dragon
      attack!

      expect(game.choices.first.choices).to contain_exactly(bears)
    end

    it "offers nothing when no creature card has lesser power" do
      angel
      attack!

      expect(game.choices).to be_empty
      expect(angel.zone).to be_hand
    end

    it "does not offer noncreature cards" do
      p1.hand.add(Card("Island", owner: p1))
      attack!

      expect(game.choices).to be_empty
    end

    it "rejects a card with too much power" do
      bears
      angel
      attack!

      expect { game.resolve_choice!(targets: [angel]) }.to raise_error(ArgumentError)
      expect(angel.zone).to be_hand
    end

    it "may be declined" do
      bears
      attack!
      game.skip_choice!

      expect(bears.zone).to be_hand
      expect(game.choices).to be_empty
    end

    it "does not trigger when another creature attacks" do
      bears
      horse = ResolvePermanent("Armored Warhorse", owner: p1)
      attack!(attacker: horse)

      expect(game.choices).to be_empty
      expect(bears.zone).to be_hand
    end

    it "can attack a planeswalker" do
      bears
      walker = ResolvePermanent("Ob Nixilis Reignited", owner: p2)
      attack!(target: walker)
      game.resolve_choice!(targets: [bears])

      permanent = p1.permanents.find { _1.card == bears }
      expect(current_turn.combat.attack_for_attacker(permanent).target).to eq(walker)
    end

    it "does not use the opponent's hand" do
      p2.hand.add(Card("Grizzly Bears", owner: p2))
      attack!

      expect(game.choices).to be_empty
    end
  end
end
