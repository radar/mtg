# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CautiousSurvivor do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:survivor) { ResolvePermanent("Cautious Survivor", owner: p1) }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 4/4" do
    expect(survivor.power).to eq(4)
    expect(survivor.toughness).to eq(4)
  end

  it "gains 2 life at second main if tapped" do
    survivor.tap!
    expect { to_second_main! }.to change { p1.life }.by(2)
  end

  it "does nothing if untapped" do
    expect { to_second_main! }.not_to(change { p1.life })
  end
end
