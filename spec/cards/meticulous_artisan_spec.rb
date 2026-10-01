# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MeticulousArtisan do
  include_context "two player game"

  let!(:artisan) { ResolvePermanent("Meticulous Artisan", owner: p1) }

  it "is a 3/3 with prowess" do
    expect([artisan.power, artisan.toughness]).to eq([3, 3])
    expect(artisan.has_keyword?(Magic::Cards::Keywords::PROWESS)).to eq(true)
  end

  it "creates a Treasure token when it enters" do
    treasure = p1.permanents.by_name("Treasure").first
    expect(treasure).not_to be_nil
    expect(treasure).to be_artifact
  end

  it "gets +1/+1 when you cast a noncreature spell" do
    p1.add_mana(green: 2)
    cast_action(player: p1, card: Card("Rampant Growth"))
      .pay_mana(green: 1, generic: { green: 1 })
      .perform
    game.settle!

    expect([artisan.power, artisan.toughness]).to eq([4, 4])
  end
end
