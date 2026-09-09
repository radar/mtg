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
end