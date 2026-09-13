# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HumbleDefector do
  include_context "two player game"

  subject(:defector) { ResolvePermanent("Humble Defector", owner: p1) }

  it "is a 2/1 Human Rogue" do
    expect(defector.power).to eq(2)
    expect(defector.toughness).to eq(1)
  end

  context "activated ability" do
    let(:ability) { defector.activated_abilities.first }

    it "draws two cards for the activating player and gives control to the target opponent" do
      hand_size_before = p1.hand.cards.count

      p1.activate_ability(ability: ability) { _1.targeting(p2) }

      game.stack.resolve!

      expect(p1.hand.cards.count).to eq(hand_size_before + 2)
      expect(defector.controller).to eq(p2)
    end

    it "cannot be activated outside the controller's turn" do
      game.next_turn

      expect(ability.requirements_met?).to be false
    end
  end
end
