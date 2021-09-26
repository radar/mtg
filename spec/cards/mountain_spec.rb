require 'spec_helper'

RSpec.describe Magic::Cards::Mountain do
  let(:p1) { Magic::Player.new }
  let(:card) { described_class.new(controller: p1) }

  it "taps for a single red mana" do
    card.tap!
    expect(p1.mana_pool[:red]).to eq(1)
  end
end
