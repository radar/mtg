# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ClawsOfValakut do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Claws of Valakut", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  it "gives enchanted creature +1/+0 for each Mountain you control and first strike" do
    ResolvePermanent("Mountain", owner: p1)
    ResolvePermanent("Mountain", owner: p1)

    p1.add_mana(red: 3)
    p1.cast(card: card) do
      _1.pay_mana(generic: { red: 1 }, red: 2)
      _1.targeting(wood_elves)
    end

    game.stack.resolve!
    game.tick!

    expect(wood_elves.power).to eq(3)
    expect(wood_elves.toughness).to eq(1)
    expect(wood_elves).to be_first_strike
  end

  it "grants no power bonus with no Mountains, but still has first strike" do
    p1.add_mana(red: 3)
    p1.cast(card: card) do
      _1.pay_mana(generic: { red: 1 }, red: 2)
      _1.targeting(wood_elves)
    end

    game.stack.resolve!
    game.tick!

    expect(wood_elves.power).to eq(1)
    expect(wood_elves).to be_first_strike
  end

  it "can target any creature" do
    opponent_creature = ResolvePermanent("Wood Elves", owner: p2)

    choices = card.target_choices

    expect(choices).to include(opponent_creature)
    expect(choices).to include(wood_elves)
  end
end
