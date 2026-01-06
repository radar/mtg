require 'spec_helper'

RSpec.describe Magic::Cards::BaronAirshipKingdom do
  include_context "two player game"

  let(:card) { Card("Baron, Airship Kingdom") }

  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Baron, Airship Kingdom").first
  end

  it "enters the battlefield tapped" do
    expect(permanent).to be_tapped
  end

  it "taps for either blue or red" do
    p1.activate_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:blue)
    end

    expect(p1.mana_pool[:blue]).to eq(1)
  end
end
