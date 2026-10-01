# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LightfootTechnique do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:technique) { Card("Lightfoot Technique", owner: p1) }

  before do
    p1.hand.add(technique)
    p1.add_mana(white: 2)
    p1.cast(card: technique) { |a| a.pay_mana(white: 1, generic: { white: 1 }).targeting(bears) }
    game.stack.resolve!
    game.tick!
  end

  it "puts a +1/+1 counter on target creature" do
    expect(bears.power).to eq(3)
    expect(bears.toughness).to eq(3)
  end

  it "grants flying and indestructible" do
    expect(bears.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(true)
    expect(bears.has_keyword?(Magic::Cards::Keywords::INDESTRUCTIBLE)).to eq(true)
  end

  it "loses the keywords but keeps the counter at end of turn" do
    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears.has_keyword?(Magic::Cards::Keywords::FLYING)).to eq(false)
    expect(bears.power).to eq(3)
  end
end
