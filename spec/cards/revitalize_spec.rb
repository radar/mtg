require 'spec_helper'

RSpec.describe Magic::Cards::Revitalize do
  include_context "two player game"

  subject { Card("Revitalize") }

  context "cast" do
    it "adds a life to controller's life total, and draws a single card" do
      expect(p1).to receive(:draw!)
      cast_and_resolve(card: subject, player: p1)
      expect(p1.life).to eq(23)

      expect(p1.graveyard.by_name("Revitalize").count).to eq(1)
    end
  end
end
