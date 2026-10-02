# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Overrun do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    p1.add_mana(green: 5)
    p1.cast(card: Card("Overrun", owner: p1)) { |a| a.pay_mana(generic: { green: 2 }, green: 3) }
    game.stack.resolve!
    game.tick!
  end

  it "gives creatures you control +3/+3 and trample until end of turn" do
    expect([bears.power, bears.toughness]).to eq([5, 5])
    expect(bears).to be_trample
  end

  it "doesn't affect opponents' creatures" do
    expect([rival.power, rival.toughness]).to eq([2, 2])
    expect(rival).not_to be_trample
  end

  it "wears off at end of turn" do
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
  end
end
