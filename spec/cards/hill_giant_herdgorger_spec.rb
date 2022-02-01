require 'spec_helper'

RSpec.describe Magic::Cards::HillGiantHerdgorger do
  include_context "two player game"

  let(:card) { described_class.new(game: game, controller: p1) }

  it "has base power and toughness" do
    expect(card.power).to eq(7)
    expect(card.toughness).to eq(6)
  end

  context "ETB Event" do
    let(:event) do
      Magic::Events::EnteredTheBattlefield.new(
        card,
      )
    end

    it "adds a life to controller's life total" do
      expect { card.receive_notification(event) }.to change { p1.life }.by(3)
    end
  end
end
