# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AxgardCavalry do
  include_context "two player game"

  let!(:cavalry) { ResolvePermanent("Axgard Cavalry", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true) }

  it "taps to give target creature haste until end of turn" do
    p1.activate_ability(ability: cavalry.activated_abilities.first) { _1.targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect(cavalry).to be_tapped
    expect(bears).to be_haste
  end
end
