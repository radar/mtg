# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ImmersturmPredator do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:predator) { ResolvePermanent("Immersturm Predator", owner: p1) }
  let(:graveyard_card) { Card("Boltwave", owner: p2) }

  it "is a 3/3 flying Vampire Dragon" do
    expect([predator.power, predator.toughness]).to eq([3, 3])
    expect(predator.has_keyword?(:flying)).to eq(true)
  end

  context "when it becomes tapped" do
    it "exiles up to one card from a graveyard and gets a +1/+1 counter" do
      p2.graveyard.add(graveyard_card)
      p1.graveyard.add(Card("Grizzly Bears", owner: p1))
      predator.tap!
      game.settle!
      game.resolve_choice!(target: graveyard_card)
      game.tick!

      expect(graveyard_card.zone).to be_exile
      expect(predator.power).to eq(4)
    end

    it "still gets the counter if you exile nothing" do
      p2.graveyard.add(graveyard_card)
      p1.graveyard.add(Card("Grizzly Bears", owner: p1))
      predator.tap!
      game.settle!
      game.skip_choice!
      game.tick!

      expect(graveyard_card.zone).to be_graveyard
      expect(predator.power).to eq(4)
    end

    it "gets the counter with no card to exile" do
      predator.tap!
      game.settle!
      game.tick!

      expect(predator.power).to eq(4)
    end
  end

  context "sacrificing another creature" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "makes it indestructible until end of turn and taps it" do
      p1.activate_ability(ability: predator.activated_abilities.first) { |a| a.pay_sacrifice(bears) }
      game.settle!
      game.skip_choice! # tapping it triggers its exile-from-a-graveyard ability
      game.tick!

      expect(bears.card.zone).to be_graveyard
      expect(predator).to be_tapped
      expect(predator.has_keyword?(:indestructible)).to eq(true)
    end

    it "can't sacrifice the Predator itself" do
      ability = predator.activated_abilities.first
      expect { p1.activate_ability(ability: ability) { |a| a.pay_sacrifice(predator) } }.to raise_error(Magic::Costs::SacrificeAnother::SourceSacrificed)
      expect(predator.zone).to be_battlefield
    end
  end
end
