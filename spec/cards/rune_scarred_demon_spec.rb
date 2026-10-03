# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RuneScarredDemon do
  include_context "two player game"

  it "is a 6/6 flying Demon" do
    demon = ResolvePermanent("Rune-Scarred Demon", owner: p1, settle: false)

    expect([demon.power, demon.toughness]).to eq([6, 6])
    expect(demon).to be_flying
    expect(demon.type?("Demon")).to be(true)
  end

  it "searches the library for any card and puts it into your hand when it enters" do
    target = Card("Lightning Bolt", owner: p1).tap { p1.library.add(_1) }
    ResolvePermanent("Rune-Scarred Demon", owner: p1)
    game.settle!
    game.resolve_choice!(targets: [target])

    expect(p1.hand).to include(target)
    expect(p1.library).not_to include(target)
  end

  it "offers every card in your library, and none of the opponent's" do
    ResolvePermanent("Rune-Scarred Demon", owner: p1)
    game.settle!

    expect(game.choices.last.choices.count).to eq(p1.library.count)
  end
end
