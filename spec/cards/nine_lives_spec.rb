require 'spec_helper'

RSpec.describe Magic::Cards::NineLives do
  include_context "two player game"
  let(:card) { Card("Nine Lives") }

  it "has hexproof" do
    expect(card.hexproof?).to eq(true)
  end
end
