# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SnowCoveredWastes do
  include_context "two player game"

  let!(:wastes) { ResolvePermanent("Snow-Covered Wastes", owner: p1) }

  it "is a basic snow land" do
    expect(wastes.types).to include(Magic::Types::Super::Basic, Magic::Types::Super::Snow, Magic::Types::Land)
  end

  it "taps for {C}" do
    p1.activate_ability(ability: wastes.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
    expect(wastes).to be_tapped
  end
end
