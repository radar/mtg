# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EscapeFromOrthanc do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:spell) { Card("Escape From Orthanc", owner: p1) }

  before do
    bears.tap!
    p1.hand.add(spell)
    p1.add_mana(white: 1)
    p1.cast(card: spell) { |a| a.pay_mana(white: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!
  end

  it "gives the target +1/+3" do
    expect([bears.power, bears.toughness]).to eq([3, 5])
    expect([other.power, other.toughness]).to eq([2, 2])
  end

  it "grants flying to the target only" do
    expect(bears.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(true)
    expect(other.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(false)
  end

  it "untaps the target" do
    expect(bears).not_to be_tapped
  end

  it "loses the bonus and flying at end of turn" do
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect(bears.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(false)
  end
end
