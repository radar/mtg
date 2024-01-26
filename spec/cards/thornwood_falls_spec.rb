require 'spec_helper'

RSpec.describe Magic::Cards::ThornwoodFalls do
  include_context "two player game"

  let(:card) { Card("Thornwood Falls") }

  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Thornwood Falls").first
  end

  it "enters the battlefield tapped" do
    game.stack.resolve!
    expect(permanent).to be_tapped
  end

  it "has the controller gain life" do
    expect(p1.life).to eq(21)
  end

  it "taps for green" do
    p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:green)
    end

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "taps for blue" do
    p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:blue)
    end

    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "cannot tap for another color" do
    expect {
      p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
        _1.choose(:red)
      end
    }.to raise_error("Invalid choice made for mana ability:")
  end
end
