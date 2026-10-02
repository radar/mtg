# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MakeAStand do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    p1.add_mana(white: 3)
    p1.cast(card: Card("Make A Stand", owner: p1)) { |a| a.pay_mana(generic: { white: 2 }, white: 1) }
    game.stack.resolve!
    game.tick!
  end

  it "gives creatures you control +1/+0 and indestructible until end of turn" do
    expect([bears.power, bears.toughness]).to eq([3, 2])
    expect(bears).to be_indestructible
  end

  it "doesn't affect opponents' creatures" do
    expect(rival.power).to eq(2)
    expect(rival).not_to be_indestructible
  end
end
