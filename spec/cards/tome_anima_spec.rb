# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TomeAnima do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:anima) { ResolvePermanent("Tome Anima", owner: p1) }
  let(:cant_be_blocked) { Magic::Cards::Keywords::CANT_BE_BLOCKED }

  it "is a 3/3 Spirit" do
    expect([anima.power, anima.toughness]).to eq([3, 3])
  end

  # go_to_main_phase! already went through the draw step, so p1 has drawn one card this turn.
  it "can be blocked after drawing one card this turn" do
    expect(anima.has_keyword?(cant_be_blocked)).to eq(false)
  end

  it "can't be blocked once you've drawn two or more cards this turn" do
    p1.draw!
    game.tick!

    expect(anima.has_keyword?(cant_be_blocked)).to eq(true)
  end

  it "ignores cards the opponent drew" do
    2.times { p2.draw! }
    game.tick!

    expect(anima.has_keyword?(cant_be_blocked)).to eq(false)
  end
end
