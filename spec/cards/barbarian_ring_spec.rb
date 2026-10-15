# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BarbarianRing do
  include_context "two player game"

  let!(:ring) { ResolvePermanent("Barbarian Ring", owner: p1) }

  def fill_graveyard(count)
    count.times { p1.graveyard.add(Card("Forest", owner: p1)) }
  end

  it "taps for {R} and deals 1 damage to you" do
    p1.activate_ability(ability: ring.activated_abilities.first)
    game.settle!

    expect(p1.mana_pool[:red]).to eq(1)
    expect(p1.life).to eq(19)
  end

  context "threshold ability" do
    def activate
      p1.add_mana(red: 1)
      p1.activate_ability(ability: ring.activated_abilities.last) do |a|
        a.pay_mana(red: 1)
        a.targeting(p2)
      end
    end

    it "sacrifices itself to deal 2 damage to any target with seven or more cards in the graveyard" do
      fill_graveyard(7)
      activate
      game.stack.resolve!

      expect(p2.life).to eq(18)
      expect(ring.zone).to be_nil
    end

    it "can target a creature" do
      fill_graveyard(7)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(red: 1)
      p1.activate_ability(ability: ring.activated_abilities.last) do |a|
        a.pay_mana(red: 1)
        a.targeting(bears)
      end
      game.stack.resolve!

      expect(p2.creatures).to be_empty
    end

    it "can't be activated with fewer than seven cards in the graveyard" do
      fill_graveyard(6)
      expect { activate }.to raise_error(Magic::IllegalAction)
      expect(p2.life).to eq(20)
    end
  end
end
