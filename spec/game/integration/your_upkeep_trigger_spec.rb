require 'spec_helper'

RSpec.describe Magic::Game, "your upkeep trigger" do
  include_context "two player game"

  let!(:dranas_emissary) { ResolvePermanent("Drana's Emissary", controller: p1) }

  it "upkeep triggers dranas emissary's ability" do
    current_turn.untap!
    current_turn.upkeep!

    expect(p1.life).to eq(21)
    expect(p2.life).to eq(19)
  end
end
