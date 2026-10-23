# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SorinOfHouseMarkov do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:sorin) { ResolvePermanent("Sorin of House Markov", owner: p1) }

  def second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  def walker = game.battlefield.controlled_by(p1).find { _1.name == "Sorin, Ravenous Neonate" }

  it "has lifelink" do
    expect(sorin).to have_keyword(:lifelink)
  end

  context "extort" do
    def cast_bears
      bears = Card("Grizzly Bears", owner: p1)
      p1.hand.add(bears)
      p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      bears
    end

    before { p1.add_mana(green: 2) }

    it "drains when the controller pays {W/B}" do
      p1.add_mana(black: 1)
      cast_bears
      game.settle!
      game.resolve_choice!
      expect(p2.life).to eq(19)
      expect(p1.life).to eq(21)
    end

    it "does nothing when declined" do
      p1.add_mana(black: 1)
      cast_bears
      game.settle!
      game.skip_choice!
      expect(p2.life).to eq(20)
    end

    it "does not ask when no {W/B} can be paid" do
      cast_bears
      game.settle!
      expect(game.choices).to be_empty
    end
  end

  context "at the postcombat main phase" do
    it "transforms after gaining 3 or more life" do
      p1.gain_life(3)
      game.settle!
      second_main!
      game.resolve_choice! if game.choices.any?
      game.settle!
      expect(walker).to be_planeswalker
      expect(walker.loyalty).to eq(3)
    end

    it "stays a creature after gaining less than 3 life" do
      p1.gain_life(2)
      game.settle!
      second_main!
      expect(walker).to be_nil
    end
  end

  context "as a planeswalker" do
    let!(:walker) do
      sorin.exile_and_return_transformed!
      game.settle!
      game.battlefield.controlled_by(p1).find { _1.name == "Sorin, Ravenous Neonate" }
    end

    def activate(index, &block)
      p1.activate_loyalty_ability(ability: walker.loyalty_abilities[index], &block)
      game.stack.resolve!
      game.settle!
    end

    it "+2 creates a Food token" do
      activate(0)
      expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Food")
      expect(walker.loyalty).to eq(5)
    end

    it "-1 deals damage equal to life gained this turn" do
      p1.gain_life(4)
      game.settle!
      activate(1) { _1.targeting(p2) }
      expect(p2.life).to eq(16)
    end

    it "-6 steals a creature, makes it a Vampire, and gives lifelink with another white permanent" do
      walker.change_loyalty!(3)
      ResolvePermanent("Serra Angel", owner: p1)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      activate(2) { _1.targeting(bears) }
      expect(bears.controller).to eq(p1)
      expect(bears.type?("Vampire")).to be(true)
      expect(bears).to have_keyword(:lifelink)
    end

    it "-6 gives no lifelink counter without another white permanent" do
      walker.change_loyalty!(3)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      activate(2) { _1.targeting(bears) }
      expect(bears.controller).to eq(p1)
      expect(bears).not_to have_keyword(:lifelink)
    end
  end
end
