# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BloodfellCaves do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:caves) do
    p1.play_land(land: Card("Bloodfell Caves"))
    game.settle!
    p1.permanents.by_name("Bloodfell Caves").first
  end

  it "enters tapped" do
    expect(caves).to be_tapped
  end

  it "gains 1 life when it enters" do
    expect(p1.life).to eq(21)
  end

  it "taps for black" do
    caves.untap!
    p1.activate_ability(ability: caves.activated_abilities.first) { _1.choose(:black) }
    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "taps for red" do
    caves.untap!
    p1.activate_ability(ability: caves.activated_abilities.first) { _1.choose(:red) }
    expect(p1.mana_pool[:red]).to eq(1)
  end
end
