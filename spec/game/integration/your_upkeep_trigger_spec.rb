require 'spec_helper'

RSpec.describe Magic::Game, "your upkeep trigger" do
  include_context "two player game"

  let(:dranas_emissary) { Card("Drana's Emissary", controller: p1) }

  before do
    game.battlefield.add(dranas_emissary)
  end

  it "upkeep triggers dranas emissary's ability" do
    current_turn.upkeep!

    expect(p1.life).to eq(21)
    expect(p2.life).to eq(19)
  end
end
