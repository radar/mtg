# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GleamingSplendor do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:splendor) { ResolvePermanent("Gleaming Splendor", owner: p1) }

  def treasures = p1.permanents.select { _1.name == "Treasure" }

  it "creates a Treasure when an opponent draws their second card each turn" do
    p2.draw!
    game.settle!
    expect(treasures.count).to eq(0)
    p2.draw!
    game.settle!
    expect(treasures.count).to eq(1)
    p2.draw!
    game.settle!
    expect(treasures.count).to eq(1)
  end

  it "doesn't trigger on your own second draw" do
    2.times { p1.draw! }
    game.settle!
    expect(treasures.count).to eq(0)
  end

  it "has two target players each draw a card for {2}{W}" do
    p1.add_mana(white: 3)
    expect do
      p1.activate_ability(ability: splendor.activated_abilities.first) do
        _1.pay_mana(generic: { white: 2 }, white: 1)
      end
      game.stack.resolve!
    end.to change { p1.hand.count }.by(1).and change { p2.hand.count }.by(1)
  end
end
