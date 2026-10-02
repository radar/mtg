# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BrazenScourge do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 3/3 Gremlin with haste" do
    scourge = ResolvePermanent("Brazen Scourge", owner: p1, summoning_sick: true)
    game.tick!

    expect([scourge.power, scourge.toughness]).to eq([3, 3])
    expect(scourge).to be_haste
    expect(scourge).not_to be_summoning_sick
  end
end
