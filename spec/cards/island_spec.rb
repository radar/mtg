require 'spec_helper'

RSpec.describe Magic::Cards::Island do
  let(:p1) { Magic::Player.new }
  let(:card) { described_class.new(controller: p1) }

  it "taps for a single blue mana" do
    card.tap!
    expect(p1.mana_pool[:blue]).to eq(1)
    expect(card).to be_tapped
  end
end
