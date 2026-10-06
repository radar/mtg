require "spec_helper"

RSpec.describe Magic::Cards::CarpetOfFlowers do
  include_context "two player game"

  it "adds mana equal to an opponent's Islands during the first main phase" do
    ResolvePermanent("Island", owner: p2)
    ResolvePermanent("Carpet of Flowers", owner: p1)
    go_to_main_phase!
    game.resolve_choice!(color: :blue)

    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "does not add mana a second time in the second main phase if it already did this turn" do
    ResolvePermanent("Island", owner: p2)
    ResolvePermanent("Carpet of Flowers", owner: p1)
    go_to_main_phase!
    game.resolve_choice!(color: :blue)

    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!

    expect(game.choices).to be_empty
  end

  it "adds mana in the second main phase if it did not in the first" do
    ResolvePermanent("Carpet of Flowers", owner: p1)
    go_to_main_phase!
    ResolvePermanent("Island", owner: p2)

    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
    game.resolve_choice!(color: :green)

    expect(p1.mana_pool[:green]).to eq(1)
  end
end