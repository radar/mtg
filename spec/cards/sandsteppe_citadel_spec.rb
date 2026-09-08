require "spec_helper"

RSpec.describe Magic::Cards::SandsteppeCitadel do
  include_context "two player game"

  let(:card) { Card("Sandsteppe Citadel") }
  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Sandsteppe Citadel").first
  end

  it "enters the battlefield tapped" do
    game.stack.resolve!

    expect(permanent).to be_tapped
  end

  it "taps for white" do
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:white) }

    expect(p1.mana_pool[:white]).to eq(1)
  end

  it "taps for black" do
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:black) }

    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "taps for green" do
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "cannot tap for another color" do
    expect {
      p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:blue) }
    }.to raise_error(/Invalid choice made for mana ability/)
  end
end