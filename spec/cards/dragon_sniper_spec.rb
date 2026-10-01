# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DragonSniper do
  include_context "two player game"

  let!(:sniper) { ResolvePermanent("Dragon Sniper", owner: p1) }

  it "is a 1/1 Human Archer" do
    expect(sniper.power).to eq(1)
    expect(sniper.toughness).to eq(1)
    expect(sniper.type?("Archer")).to eq(true)
  end

  it "has reach, vigilance and deathtouch" do
    expect(sniper.has_keyword?(Magic::Cards::Keywords::REACH)).to eq(true)
    expect(sniper.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(true)
    expect(sniper.has_keyword?(Magic::Cards::Keywords::DEATHTOUCH)).to eq(true)
  end
end
