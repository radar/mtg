# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SnakeskinVeil do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:veil) { Card("Snakeskin Veil", owner: p1) }

  before do
    p1.hand.add(veil)
    p1.add_mana(green: 1)
    p1.cast(card: veil) { |a| a.pay_mana(green: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!
  end

  it "puts a +1/+1 counter on the creature" do
    expect([bears.power, bears.toughness]).to eq([3, 3])
  end

  it "gives it hexproof until end of turn" do
    expect(bears.has_keyword?(Magic::Cards::Keywords::HEXPROOF)).to eq(true)

    current_turn.end!
    current_turn.cleanup!
    game.tick!
    expect(bears.has_keyword?(Magic::Cards::Keywords::HEXPROOF)).to eq(false)
    expect(bears.power).to eq(3)
  end

  it "stops opponents targeting the creature" do
    expect(bears.can_be_targeted_by?(Card("Grizzly Bears", owner: p2), controller: p2)).to eq(false)
    expect(bears.can_be_targeted_by?(Card("Grizzly Bears", owner: p1), controller: p1)).to eq(true)
  end

  it "only targets creatures you control" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    expect(veil.target_choices).to include(bears)
    expect(veil.target_choices).not_to include(theirs)
  end
end
