# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DeathcapGlade do
  include_context "two player game"
  before { go_to_main_phase! }

  def play_glade
    p1.play_land(land: Card("Deathcap Glade"))
    game.settle!
    p1.permanents.by_name("Deathcap Glade").first
  end

  it "enters tapped with fewer than two other lands" do
    ResolvePermanent("Forest", owner: p1)
    expect(play_glade).to be_tapped
  end

  it "enters untapped with two other lands" do
    2.times { ResolvePermanent("Forest", owner: p1) }
    expect(play_glade).not_to be_tapped
  end

  it "taps for black or green" do
    2.times { ResolvePermanent("Forest", owner: p1) }
    glade = play_glade
    p1.activate_ability(ability: glade.activated_abilities.first) { _1.choose(:black) }
    expect(p1.mana_pool[:black]).to eq(1)
    glade.untap!
    p1.activate_ability(ability: glade.activated_abilities.first) { _1.choose(:green) }
    expect(p1.mana_pool[:green]).to eq(1)
  end
end
