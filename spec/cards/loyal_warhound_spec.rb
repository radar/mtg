# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LoyalWarhound do
  include_context "two player game"

  before do
    p1.library.add(Card("Plains", owner: p1))
    p1.library.add(Card("Forest", owner: p1))
  end

  it "is a 3/1 with vigilance" do
    hound = ResolvePermanent("Loyal Warhound", owner: p1)
    expect([hound.power, hound.toughness]).to eq([3, 1])
    expect(hound).to have_keyword(:vigilance)
  end

  it "searches for a basic Plains, tapped, when an opponent controls more lands" do
    2.times { ResolvePermanent("Island", owner: p2) }
    ResolvePermanent("Loyal Warhound", owner: p1)

    choice = game.choices.last
    expect(choice.choices.map(&:name).uniq).to eq(["Plains"])

    plains = choice.choices.first
    game.resolve_choice!(targets: [plains])
    expect(game.battlefield.by_card(plains).first).to be_tapped
  end

  it "does nothing when the opponent doesn't control more lands" do
    ResolvePermanent("Island", owner: p2)
    ResolvePermanent("Plains", owner: p1)
    ResolvePermanent("Loyal Warhound", owner: p1)

    expect(game.choices).to be_empty
  end
end
