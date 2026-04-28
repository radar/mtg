# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::WardenOfTheWoods do
  include_context "two player game"

  let!(:warden) { ResolvePermanent("Warden Of The Woods", owner: p1) }

  it "is a 5/7 vigilance treefolk" do
    expect(warden.power).to eq(5)
    expect(warden.toughness).to eq(7)
    expect(warden).to be_vigilant
    expect(warden.card.types).to include("Treefolk")
  end

  context "when an opponent casts a spell targeting it" do
    before do
      p2.add_mana(red: 1)
      action = cast_action(card: Card("Lightning Bolt", owner: p2), player: p2)
      action.pay_mana(red: 1)
      action.targeting(warden)
      game.take_action(action)
    end

    it "the controller draws 2 cards" do
      expect(p1.hand.count).to eq(9) # started with 7 cards
    end
  end

  context "when the controller casts a spell targeting it" do
    before do
      p1.add_mana(red: 2)
      action = cast_action(card: Card("Sure Strike", owner: p1), player: p1)
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.targeting(warden)
      game.take_action(action)
    end

    it "the controller does not draw cards" do
      expect(p1.hand.count).to eq(7) # no draw triggered
    end
  end

  context "when an opponent activates an ability targeting it" do
    let!(:silent_dart) { ResolvePermanent("Silent Dart", owner: p2) }

    before do
      ability = silent_dart.activated_abilities.first
      p2.add_mana(black: 4)
      p2.activate_ability(ability: ability) do
        _1.targeting(warden).pay_mana(generic: { black: 4 }).pay(:self_sacrifice, silent_dart)
      end
    end

    it "the controller draws 2 cards" do
      expect(p1.hand.count).to eq(9) # started with 7 cards
    end
  end

  context "when the controller activates an ability targeting it" do
    let!(:selfless_savior) { ResolvePermanent("Selfless Savior", owner: p1) }

    before do
      ability = selfless_savior.activated_abilities.first
      p1.activate_ability(ability: ability) do
        _1.pay(:self_sacrifice, selfless_savior).targeting(warden)
      end
    end

    it "the controller does not draw cards" do
      expect(p1.hand.count).to eq(7) # no draw triggered
    end
  end
end
