require 'spec_helper'

RSpec.describe Magic::Cards::TempleOfEpiphany do
  include_context "two player game"

  let(:card) { Card("Temple Of Epiphany") }

  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Temple of Epiphany").first
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

  it "taps for red" do
    p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:red)
    end

    expect(p1.mana_pool[:red]).to eq(1)
  end

  it "cannot tap for another color" do
    expect {
      p1.activate_mana_ability(ability: permanent.activated_abilities.first) do
        _1.choose(:green)
      end
    }.to raise_error("Invalid choice made for mana ability:")
  end
end
