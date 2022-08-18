require 'spec_helper'

RSpec.describe Magic::Cards::BasriKet do
  include_context "two player game"

  let(:card) { Card("Basri Ket", controller: p1) }
  subject(:planeswalker) { Magic::Permanent.resolve(game: game, controller: p1, card: card) }

  context "+1 triggered ability" do
    let(:ability) { card.class::LoyaltyAbility1 }
    let(:wood_elves_card) { Card("Wood Elves", controller: p2) }
    let(:wood_elves) { Magic::Permanents::Creature.new(game: game, controller: p1, card: wood_elves_card) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "targets the wood elves" do
      action = Magic::Actions::ActivateLoyaltyAbility.new(player: p1, planeswalker: planeswalker, ability: ability)
      action.targeting(wood_elves)
      game.take_action(action)
      game.tick!

      expect(planeswalker.loyalty).to eq(4)
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
      expect(wood_elves.indestructible?).to eq(true)
    end
  end

  context "-2 triggered ability" do
    let(:ability) { card.class::LoyaltyAbility2 }

    let(:turn) { double(Magic::Game::Turn, number: 1, notify!: nil) }
    before do
      allow(game).to receive(:current_turn) { turn }
    end

    it "adds an after attackers declared step trigger" do
      action = Magic::Actions::ActivateLoyaltyAbility.new(player: p1, planeswalker: planeswalker, ability: ability)
      game.take_action(action)
      game.tick!

      expect(subject.loyalty).to eq(1)
      expect(subject.delayed_responses.count).to eq(1)
      expect(subject.delayed_responses.first[:event_type]).to eq(Magic::Events::AttackersDeclared)
    end
  end

  context "-6 triggered ability" do
    let(:ability) { card.class::LoyaltyAbility3 }

    it "emblem for creating white soldier creature tokens and putting counters on all creatures" do
      action = Magic::Actions::ActivateLoyaltyAbility.new(player: p1, planeswalker: planeswalker, ability: ability)
      game.take_action(action)
      game.tick!

      expect(game.emblems.count).to eq(1)
    end
  end
end
