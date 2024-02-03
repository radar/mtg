require 'spec_helper'

RSpec.describe Magic::Cards::RadiantFountain do
  include_context "two player game"

  let(:card) { Card("Radiant Fountain") }

  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Radiant Fountain").first
  end

  it "enters the battlefield untapped" do
    game.stack.resolve!
    expect(permanent).not_to be_tapped
  end

  it "has the controller gain life" do
    expect(p1.life).to eq(22)
  end

  it "taps for colorless" do
    p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:colorless)
    end

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "cannot tap for another color" do
    expect {
      p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
        _1.choose(:blue)
      end
    }.to raise_error(/Invalid choice made for mana ability/)
  end
end
