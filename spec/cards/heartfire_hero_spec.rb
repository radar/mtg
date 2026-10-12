# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HeartfireHero do
  include_context "two player game"

  let!(:hero) { ResolvePermanent("Heartfire Hero", owner: p1) }

  def target_with_growth
    p1.add_mana(green: 2)
    p1.cast(card: Card("Titanic Growth", owner: p1)) do
      _1.auto_pay_mana
      _1.targeting(hero)
    end
  end

  describe "valiant" do
    it "gets a +1/+1 counter the first time it is targeted each turn" do
      target_with_growth
      game.stack.resolve!
      game.settle!
      game.tick!

      expect(hero.power).to eq(1 + 1 + 4)
    end

    it "does not trigger a second time in the same turn" do
      2.times do
        target_with_growth
        game.stack.resolve!
        game.settle!
      end
      game.tick!

      expect(hero.power).to eq(1 + 1 + 8)
    end

    it "does not trigger when an opponent targets it" do
      go_to_main_phase_for!(p2)
      p2.add_mana(green: 2)
      p2.cast(card: Card("Titanic Growth", owner: p2)) do
        _1.auto_pay_mana
        _1.targeting(hero)
      end
      game.stack.resolve!
      game.settle!
      game.tick!

      expect(hero.power).to eq(1 + 4)
    end
  end

  describe "when it dies" do
    it "deals damage equal to its power to each opponent" do
      hero.add_counter("+1/+1")
      game.tick!
      hero.destroy!
      game.settle!

      expect(p2.life).to eq(18)
    end
  end
end
