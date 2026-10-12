# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlorianVoldarenScion do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:florian) { ResolvePermanent("Florian Voldaren Scion", owner: p1) }

  def second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "has first strike" do
    expect(florian).to have_keyword(:first_strike)
  end

  it "does nothing if no opponent lost life this turn" do
    second_main!

    expect(game.choices).to be_empty
  end

  it "looks at as many cards as the life opponents lost, exiles one and lets you play it this turn" do
    p2.lose_life(3)
    top = p1.library.cards.first(3)
    size = p1.library.count
    second_main!
    chosen = top[1]
    game.resolve_choice!(target: chosen)

    expect(chosen.zone).to be_exile
    expect(game.play_permissions.permits?(chosen, p1)).to be(true)
    expect(p1.library.count).to eq(size - 1)
    expect(p1.library.last(2).map(&:object_id)).to match_array((top - [chosen]).map(&:object_id))
  end

  it "counts life lost to damage" do
    p2.take_damage(2)
    top = p1.library.cards.first(2)
    second_main!

    expect(game.choices.last.choices.map(&:object_id)).to match_array(top.map(&:object_id))
  end

  it "doesn't count your own life loss" do
    p1.lose_life(4)
    second_main!

    expect(game.choices).to be_empty
  end
end
