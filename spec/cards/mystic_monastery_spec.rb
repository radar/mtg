# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MysticMonastery do
  include_context "two player game"

  let!(:land) { ResolvePermanent("Mystic Monastery", owner: p1) }

  it "enters tapped" do
    expect(land).to be_tapped
  end

  it "taps for {U}, {R} or {W}" do
    %i[blue red white].each do |color|
      land.untap!
      p1.activate_ability(ability: land.activated_abilities.first) { |a| a.choose(color) }
      expect(p1.mana_pool[color]).to eq(1)
    end
  end
end
