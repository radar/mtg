# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FoulOrchard do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) do
    p1.play_land(land: Card("Foul Orchard"))
    game.settle!
    p1.permanents.by_name("Foul Orchard").first
  end

  it "enters the battlefield tapped" do
    expect(permanent).to be_tapped
  end

  it "taps for black" do
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:black) }
    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "taps for green" do
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:green) }
    expect(p1.mana_pool[:green]).to eq(1)
  end

  it "cannot tap for another color" do
    permanent.untap!
    expect {
      p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:red) }
    }.to raise_error(/Invalid choice made for mana ability/)
  end
end
