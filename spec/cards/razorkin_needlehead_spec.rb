# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RazorkinNeedlehead do
  include_context "two player game"

  let!(:needlehead) { ResolvePermanent("Razorkin Needlehead", owner: p1) }

  before { game.tick! }

  it "is a 2/2" do
    expect(needlehead.power).to eq(2)
    expect(needlehead.toughness).to eq(2)
  end

  it "has first strike during its controller's turn" do
    go_to_main_phase!
    game.tick!
    expect(game.current_turn.active_player).to eq(p1)
    expect(needlehead).to be_first_strike
  end

  it "does not have first strike during the opponent's turn" do
    go_to_main_phase_for!(p2)
    game.tick!
    expect(needlehead).not_to be_first_strike
  end

  it "deals 1 damage to an opponent who draws a card" do
    expect { p2.draw!; game.settle! }.to change { p2.life }.by(-1)
  end

  it "does not damage its controller for drawing" do
    expect { p1.draw!; game.settle! }.not_to(change { p1.life })
  end
end
