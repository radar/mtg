# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ObNixilisReignited do
  include_context "two player game"

  let(:card) { Card("Ob Nixilis Reignited") }
  subject(:planeswalker) { Magic::Permanent.resolve(game: game, owner: p1, card: card) }

  it "enters with 5 loyalty" do
    expect(planeswalker.loyalty).to eq(5)
  end

  context "+1 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities.first }

    it "draws a card and loses 1 life" do
      starting_life = p1.life
      starting_hand_size = p1.hand.count

      p1.activate_loyalty_ability(ability: ability)
      game.stack.resolve!
      game.tick!

      expect(planeswalker.loyalty).to eq(6)
      expect(p1.hand.count).to eq(starting_hand_size + 1)
      expect(p1.life).to eq(starting_life - 1)
    end
  end

  context "-3 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[1] }
    let!(:opposing_creature) { ResolvePermanent("Wood Elves", owner: p2) }

    it "destroys target creature" do
      p1.activate_loyalty_ability(ability: ability) { _1.targeting(opposing_creature) }
      game.stack.resolve!
      game.tick!

      expect(planeswalker.loyalty).to eq(2)
      expect(opposing_creature.card.zone).to be_graveyard
    end
  end

  context "-8 loyalty ability" do
    let(:ability) { planeswalker.loyalty_abilities[2] }

    it "gives target opponent an emblem that makes them lose 2 life whenever a player draws a card" do
      p1.activate_loyalty_ability(ability: ability) { _1.targeting(p2) }
      game.stack.resolve!
      game.tick!

      expect(game.emblems.count).to eq(1)

      starting_life = p2.life
      p1.draw!

      expect(p2.life).to eq(starting_life - 2)
    end
  end
end
