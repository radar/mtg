require 'spec_helper'

RSpec.describe Magic::Cards::NineLives do
  include_context "two player game"
  let(:card) { described_class.new(game: game) }

  it "has hexproof" do
    expect(card.hexproof?).to eq(true)
  end
end
