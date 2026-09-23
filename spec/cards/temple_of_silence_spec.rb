require 'spec_helper'

RSpec.describe Magic::Cards::TempleOfSilence do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Temple Of Silence") }

  let!(:permanent) do
    p1.play_land(land: card)
    game.settle!
    p1.permanents.by_name("Temple of Silence").first
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
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:white)
    end

    expect(p1.mana_pool[:white]).to eq(1)
  end

  it "taps for black" do
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) do
      _1.choose(:black)
    end

    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "cannot tap for another color" do
    permanent.untap!
    expect {
      p1.activate_ability(ability: permanent.activated_abilities.first) do
        _1.choose(:green)
      end
    }.to raise_error(/Invalid choice made for mana ability/)
  end
end
