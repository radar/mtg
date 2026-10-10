# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AbandonedCampground do
  include_context "two player game"
  before { go_to_main_phase! }

  def play_land
    p1.play_land(land: Card("Abandoned Campground"))
    game.settle!
    p1.permanents.by_name("Abandoned Campground").first
  end

  it "enters tapped when no player has 13 or less life" do
    expect(play_land).to be_tapped
  end

  it "enters untapped when a player has 13 or less life" do
    p2.lose_life(7)
    expect(play_land).not_to be_tapped
  end

  it "taps for white" do
    permanent = play_land
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:white) }
    expect(p1.mana_pool[:white]).to eq(1)
  end

  it "taps for blue" do
    permanent = play_land
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:blue) }
    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "cannot tap for another color" do
    permanent = play_land
    permanent.untap!
    expect {
      p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(:red) }
    }.to raise_error(/Invalid choice made for mana ability/)
  end
end
