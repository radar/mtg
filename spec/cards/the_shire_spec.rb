# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheShire do
  include_context "two player game"

  def food_ability(shire) = shire.activated_abilities.find { _1.is_a?(described_class::FoodAbility) }

  def foods = p1.permanents.select { _1.type?("Food") }

  it "enters tapped without a legendary creature" do
    ResolvePermanent("Grizzly Bears", owner: p1)

    expect(ResolvePermanent("The Shire", owner: p1)).to be_tapped
  end

  it "enters untapped if you control a legendary creature" do
    ResolvePermanent("Elanor Gardner", owner: p1)
    game.settle!

    expect(ResolvePermanent("The Shire", owner: p1)).not_to be_tapped
  end

  it "does not count an opponent's legendary creature" do
    ResolvePermanent("Elanor Gardner", owner: p2)

    expect(ResolvePermanent("The Shire", owner: p1)).to be_tapped
  end

  it "taps for {G}" do
    shire = ResolvePermanent("The Shire", owner: p1)
    shire.untap!
    ability = shire.activated_abilities.find { _1.is_a?(Magic::ManaAbility) }
    p1.activate_ability(ability: ability)

    expect(p1.mana_pool[:green]).to eq(1)
  end

  context "Food ability" do
    before { go_to_main_phase! }

    let!(:shire) { ResolvePermanent("The Shire", owner: p1).tap(&:untap!) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "creates a Food by paying {1}{G}, tapping itself and tapping a creature" do
      p1.add_mana(green: 2)
      p1.activate_ability(ability: food_ability(shire)) do |a|
        a.pay_mana(generic: { green: 1 }, green: 1).pay_multi_tap([bears])
      end
      game.stack.resolve!
      game.tick!

      expect(foods.count).to eq(1)
      expect(shire).to be_tapped
      expect(bears).to be_tapped
      expect(p1.mana_pool[:green]).to eq(0)
    end

    it "cannot be paid without an untapped creature" do
      bears.tap!

      expect(food_ability(shire).costs.last.can_pay?(p1)).to be(false)
    end

    it "cannot tap an opponent's creature" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(green: 2)

      expect do
        p1.activate_ability(ability: food_ability(shire)) do |a|
          a.pay_mana(generic: { green: 1 }, green: 1).pay_multi_tap([theirs])
        end
      end.to raise_error(/Tap exactly 1/)
      expect(foods.count).to eq(0)
    end
  end
end
