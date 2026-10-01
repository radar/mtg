# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NomadOutpost do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:outpost) do
    p1.play_land(land: Card("Nomad Outpost"))
    game.settle!
    p1.permanents.by_name("Nomad Outpost").first
  end

  it "enters tapped" do
    expect(outpost).to be_tapped
  end

  %i[red white black].each do |color|
    it "taps for #{color}" do
      outpost.untap!
      p1.activate_ability(ability: outpost.activated_abilities.first) { _1.choose(color) }
      expect(p1.mana_pool[color]).to eq(1)
    end
  end
end
