require 'spec_helper'

RSpec.describe Magic::Cards::JungleHollow do
  include_context "two player game"

  let(:card) { Card("Jungle Hollow") }

  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Jungle Hollow").first
  end

  it "enters the battlefield tapped" do
    game.stack.resolve!
    expect(permanent).to be_tapped
  end

  it "has the controller gain life" do
    expect(p1.life).to eq(21)
  end

  it "taps for either black or green" do
    p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:black)
    end

    expect(p1.mana_pool[:black]).to eq(1)
  end
end
