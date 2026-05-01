# frozen_string_literal: true
require "spec_helper"

RSpec.describe Magic::Cards::InvigoratingSurge do
  include_context "two player game"

  let(:card) { Card("Invigorating Surge") }

  context "targeting a creature with no +1/+1 counters" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "puts one +1/+1 counter, then doubles to two" do
      cast_and_resolve(card: card, player: p1, targeting: wood_elves)

      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end
  end

  context "targeting a creature with two +1/+1 counters" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    before do
      wood_elves.add_counter("+1/+1", amount: 2)
    end

    it "adds one to make three, then doubles to six" do
      cast_and_resolve(card: card, player: p1, targeting: wood_elves)

      expect(wood_elves.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(6)
    end
  end

  context "target choices" do
    let!(:my_wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
    let!(:opponents_wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "only targets creatures controlled by the caster" do
      expect(card.target_choices).to include(my_wood_elves)
      expect(card.target_choices).not_to include(opponents_wood_elves)
    end
  end
end
