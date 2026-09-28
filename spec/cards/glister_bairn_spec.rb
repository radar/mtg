# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlisterBairn do
  include_context "two player game"

  let!(:bairn) { ResolvePermanent("Glister Bairn", owner: p1) }
  let!(:trooper) { ResolvePermanent("Alaborn Trooper", owner: p1) }

  it "gives another target creature you control +X/+X at the beginning of combat on your turn" do
    go_to_main_phase!
    power = trooper.power
    current_turn.beginning_of_combat!

    # The only legal target is chosen automatically.
    # Glister Bairn (G and U) + Alaborn Trooper (W) = 3 colors
    expect(trooper.power).to eq(power + 3)
    expect(bairn.power).to eq(1)
  end

  it "does not trigger on the opponent's turn" do
    game.next_turn
    go_to_main_phase!
    current_turn.beginning_of_combat!

    expect(game.choices).to be_empty
  end
end
