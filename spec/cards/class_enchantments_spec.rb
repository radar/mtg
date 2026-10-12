# frozen_string_literal: true

require "spec_helper"

# Bloomburrow's Class enchantments: level up for each level's cost, as a sorcery.
RSpec.describe "Class enchantments" do
  include_context "two player game"

  before { go_to_main_phase! }

  # `pool` is the mana to add, `payment` how it is spent on the next level's cost.
  def level_up(permanent, pool, payment)
    p1.add_mana(**pool)
    ability = permanent.activated_abilities.find { _1.is_a?(Magic::Cards::ClassEnchantment::LevelUp) }
    p1.activate_ability(ability: ability) { |action| action.pay_mana(payment) }
    game.stack.resolve!
    game.settle!
  end

  describe "Stormchaser's Talent" do
    let!(:talent) { ResolvePermanent("Stormchaser's Talent", owner: p1) }

    it "creates an Otter token with prowess when it enters" do
      otter = p1.creatures.find { _1.name == "Otter" }

      expect(otter.power).to eq(1)
      expect(otter.colors).to match_array(%i[blue red])
      expect(otter.keywords).to include(Magic::Cards::Keywords::PROWESS)
      expect(talent.level).to eq(1)
    end

    it "levels up to 2 and returns an instant or sorcery from your graveyard" do
      spell = Card("Titanic Growth", owner: p1)
      p1.graveyard.add(spell)
      level_up(talent, { blue: 4 }, { generic: { blue: 3 }, blue: 1 })
      game.resolve_choice!(target: spell) if game.choices.any?

      expect(talent.level).to eq(2)
      expect(p1.hand.cards).to include(spell)
    end

    it "can't skip a level" do
      abilities = talent.activated_abilities.select { _1.is_a?(Magic::Cards::ClassEnchantment::LevelUp) }

      expect(abilities.first.costs.first.cost).to eq(generic: 3, blue: 1)
    end

    it "creates an Otter whenever you cast an instant or sorcery at level 3" do
      2.times { |i| talent.level_up! }
      before = p1.creatures.count
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(talent.then { p1.creatures.first }) }
      game.settle!

      expect(p1.creatures.count).to eq(before + 1)
    end

    it "doesn't create an Otter on casting before level 3" do
      before = p1.creatures.count
      p1.add_mana(green: 2)
      p1.cast(card: Card("Titanic Growth", owner: p1)) { _1.auto_pay_mana; _1.targeting(p1.creatures.first) }
      game.settle!

      expect(p1.creatures.count).to eq(before)
    end
  end
end
