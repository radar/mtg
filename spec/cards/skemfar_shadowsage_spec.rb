# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkemfarShadowsage do
  include_context "two player game"

  let(:mode) { Magic::Cards::SkemfarShadowsage::ModeChoice }

  before do
    2.times { ResolvePermanent("Llanowar Elves", owner: p1) }
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Llanowar Elves", owner: p2)
  end

  let!(:shadowsage) { ResolvePermanent("Skemfar Shadowsage", owner: p1) }

  it "is a 2/5 Elf Cleric" do
    expect(shadowsage.power).to eq(2)
    expect(shadowsage.toughness).to eq(5)
    expect(shadowsage.type?("Cleric")).to be true
  end

  it "drains each opponent for the most creatures you control sharing a type" do
    game.resolve_choice!(mode: mode::DRAIN)

    expect(p2.life).to eq(17)
    expect(p1.life).to eq(20)
  end

  it "gains life for the most creatures you control sharing a type" do
    game.resolve_choice!(mode: mode::GAIN)

    expect(p1.life).to eq(23)
    expect(p2.life).to eq(20)
  end
end
