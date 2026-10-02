# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PreposterousProportions do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    p1.add_mana(green: 7)
    p1.cast(card: Card("Preposterous Proportions", owner: p1)) { |a| a.pay_mana(generic: { green: 5 }, green: 2) }
    game.stack.resolve!
    game.tick!
  end

  it "gives creatures you control +10/+10 and vigilance until end of turn" do
    expect([bears.power, bears.toughness]).to eq([12, 12])
    expect(bears).to be_vigilant
  end

  it "doesn't affect opponents' creatures" do
    expect([rival.power, rival.toughness]).to eq([2, 2])
  end
end
