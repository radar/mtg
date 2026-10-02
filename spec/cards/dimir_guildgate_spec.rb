# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DimirGuildgate do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Dimir Guildgate") }

  let!(:permanent) do
    p1.play_land(land: card)
    p1.permanents.by_name("Dimir Guildgate").first
  end

  def tap_for(color)
    permanent.untap!
    p1.activate_ability(ability: permanent.activated_abilities.first) { _1.choose(color) }
  end

  it "is a Gate" do
    expect(permanent.types).to include(Magic::Types::Lands::Gate)
  end

  it "enters the battlefield tapped" do
    expect(permanent).to be_tapped
  end

  it "taps for blue" do
    tap_for(:blue)
    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "taps for black" do
    tap_for(:black)
    expect(p1.mana_pool[:black]).to eq(1)
  end

  it "cannot tap for a colour outside its identity" do
    expect { tap_for(:red) }.to raise_error(/Invalid choice/)
    expect(p1.mana_pool[:red]).to eq(0)
  end
end
