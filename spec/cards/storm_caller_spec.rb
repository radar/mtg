require 'spec_helper'

RSpec.describe Magic::Cards::StormCaller do
  include_context "two player game"

  let(:card) { Card("Storm Caller") }

  it "deals 2 damage to each opponent" do
    p2_starting_life = p2.life
    card.resolve!(p1)

    expect(p2.life).to eq(p2_starting_life - 2)
  end
end
