require 'spec_helper'

RSpec.describe Magic::Cards::TempleOfMystery do
  include_context "two player game"

  let(:card) { Card("Temple Of Mystery") }

  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Temple of Mystery").first
  end

  it "enters the battlefield tapped" do
    game.stack.resolve!
    expect(permanent).to be_tapped
  end

  it "scries one" do
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Scry)

    game.resolve_choice!(top: [choice.choices.first])
  end

  it "taps for blue" do
    p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:blue)
    end

    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "taps for green" do
    p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:green)
    end

    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "cannot tap for another color" do
    expect {
      p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
        _1.choose(:black)
      end
    }.to raise_error("Invalid choice made for mana ability:")
  end
end
