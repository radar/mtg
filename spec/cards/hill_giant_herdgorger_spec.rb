require 'spec_helper'

RSpec.describe Magic::Cards::HillGiantHerdgorger do
  include_context "two player game"

  let(:card) { Card("Hill Giant Herdgorger") }

  it "has base power and toughness" do
    expect(card.base_power).to eq(7)
    expect(card.base_toughness).to eq(6)
  end

  context "ETB Event" do
    it "adds a life to controller's life total" do
      expect { ResolvePermanent(card.name, owner: p1) }.to change { p1.life }.by(3)
    end
  end
end
