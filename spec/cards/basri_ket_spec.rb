require 'spec_helper'

RSpec.describe Magic::Cards::BasriKet do
  include_context "two player game"

  let(:card) { Card("Basri Ket") }
  subject(:planeswalker) { Magic::Permanent.resolve(game: game, owner: p1, card: card) }

  context "+1 triggered ability" do
    let(:ability) { planeswalker.loyalty_abilities.first }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "targets the wood elves" do
      p1.activate_loyalty_ability(ability: ability) do
        _1.targeting(wood_elves)
      end
      game.tick!

      expect(planeswalker.loyalty).to eq(4)
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
      expect(wood_elves.indestructible?).to eq(true)
    end
  end

  context "-2 triggered ability" do
    let(:ability) { planeswalker.loyalty_abilities[1] }

    let(:turn) { double(Magic::Game::Turn, number: 1, notify!: nil) }
    before do
      allow(game).to receive(:current_turn) { turn }
    end

    it "adds an after attackers declared step trigger" do
      p1.activate_loyalty_ability(ability: ability)
      game.tick!

      expect(subject.loyalty).to eq(1)
      expect(subject.delayed_responses.count).to eq(1)
      expect(subject.delayed_responses.first[:event_type]).to eq(Magic::Events::PreliminaryAttackersDeclared)
    end
  end

  context "-6 triggered ability" do
    let(:ability) { planeswalker.loyalty_abilities[2] }

    it "emblem for creating white soldier creature tokens and putting counters on all creatures" do
      p1.activate_loyalty_ability(ability: ability)
      game.tick!

      expect(game.emblems.count).to eq(1)
    end
  end
end
