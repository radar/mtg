# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::SetessanTraining do
  include_context "two player game"

  let(:card) { Card("Setessan Training", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  it "draws a card and gives +1/+0 and trample to enchanted creature" do
    p1.add_mana(green: 2)
    expect(p1).to receive(:draw!).once

    p1.cast(card: card) do
      _1.pay_mana(generic: { green: 1 }, green: 1)
      _1.targeting(wood_elves)
    end

    game.stack.resolve!
    game.tick!

    expect(wood_elves.power).to eq(2)
    expect(wood_elves.toughness).to eq(1)
    expect(wood_elves).to be_trample
  end

  it "can only target creatures you control" do
    opponent_creature = ResolvePermanent("Wood Elves", owner: p2)

    p1.add_mana(green: 2)
    choices = card.target_choices

    expect(choices).not_to include(opponent_creature)
    expect(choices).to include(wood_elves)
  end
end
