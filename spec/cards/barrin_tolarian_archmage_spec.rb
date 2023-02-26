require 'spec_helper'

RSpec.describe Magic::Cards::BarrinTolarianArchmage do
  include_context "two player game"

  subject(:permanent) { ResolvePermanent("Barrin, Tolarian Archmage", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  let!(:wood_elves_2) { ResolvePermanent("Wood Elves", owner: p2) }
  let!(:basri_ket) { ResolvePermanent("Basri Ket", owner: p1) }

  it "returns a creature" do
    subject.entered_the_battlefield!
    game.resolve_pending_effect(wood_elves)

    expect(wood_elves.zone).to be_nil
    expect(wood_elves.card.zone).to be_hand

    turn = game.current_turn

    turn.untap!
    turn.upkeep!
    turn.draw!
    turn.first_main!
    turn.beginning_of_combat!
    turn.declare_attackers!
    turn.end_of_combat!
    turn.second_main!

    expect(p1).to receive(:draw!)
    turn.end!
  end

  it "returns a planeswalker" do
    subject.entered_the_battlefield!
    game.resolve_pending_effect(basri_ket)

    turn = game.current_turn

    turn.untap!
    turn.upkeep!
    turn.draw!
    turn.first_main!
    turn.beginning_of_combat!
    turn.declare_attackers!
    turn.end_of_combat!
    turn.second_main!

    expect(basri_ket.zone).to be_nil
    expect(basri_ket.card.zone).to be_hand
  end

  it "returns another player's creature, so does not draw a card" do
    subject.entered_the_battlefield!
    game.resolve_pending_effect(wood_elves_2)

    expect(wood_elves_2.zone).to be_nil
    expect(wood_elves_2.card.zone).to be_hand

    turn = game.current_turn

    turn.untap!
    turn.upkeep!
    turn.draw!
    turn.first_main!
    turn.beginning_of_combat!
    turn.declare_attackers!
    turn.end_of_combat!
    turn.second_main!

    expect(p1).not_to receive(:draw!)
    turn.end!
  end


end
