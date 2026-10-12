# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GnarledSage do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:sage) { ResolvePermanent("Gnarled Sage", owner: p1) }

  it "is a 4/4 with reach and no vigilance" do
    expect([sage.power, sage.toughness]).to eq([4, 4])
    expect(sage).to be_reach
    expect(sage).not_to be_vigilant
  end

  # go_to_main_phase! already went through the draw step, so p1 has drawn one card this turn.
  it "stays 4/4 after drawing one card this turn" do
    expect(p1.game.current_turn.events.count { _1.is_a?(Magic::Events::CardDraw) }).to eq(1)
    expect([sage.power, sage.toughness]).to eq([4, 4])
    expect(sage).not_to be_vigilant
  end

  it "gets +0/+2 and vigilance after drawing two cards this turn" do
    p1.draw!
    game.tick!

    expect([sage.power, sage.toughness]).to eq([4, 6])
    expect(sage).to be_vigilant
  end

  it "ignores cards the opponent drew" do
    2.times { p2.draw! }
    game.tick!
    game.tick!

    expect(sage.toughness).to eq(4)
  end
end
