# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThoughtVessel do
  include_context "two player game"

  let!(:vessel) { ResolvePermanent("Thought Vessel", owner: p1) }

  it "taps for {C}" do
    p1.activate_ability(ability: vessel.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "gives you no maximum hand size" do
    go_to_main_phase!
    5.times { p1.hand.add(Card("Forest", owner: p1)) }
    current_turn.end!
    current_turn.cleanup!

    expect(p1.hand.cards.count).to be > 7
    expect(game.choices).to be_empty
  end
end
