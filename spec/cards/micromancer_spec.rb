# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Micromancer do
  include_context "two player game"

  let!(:opt) { Card("Opt", owner: p1).tap { p1.library.add(_1) } }
  let!(:bolt) { Card("Lightning Bolt", owner: p1).tap { p1.library.add(_1) } }
  let!(:cancel) { Card("Cancel", owner: p1).tap { p1.library.add(_1) } }
  let!(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) } }

  it "is a 3/3 Human Wizard" do
    micromancer = ResolvePermanent("Micromancer", owner: p1, settle: false)

    expect([micromancer.power, micromancer.toughness]).to eq([3, 3])
  end

  it "may search for an instant or sorcery card with mana value 1 and put it into your hand" do
    ResolvePermanent("Micromancer", owner: p1)
    game.settle!
    game.resolve_choice!
    search = game.choices.last

    expect(search.choices.to_a).to contain_exactly(opt, bolt)
    game.resolve_choice!(targets: [opt])

    expect(p1.hand).to include(opt)
  end

  it "does not offer instants with another mana value or non-instant cards" do
    ResolvePermanent("Micromancer", owner: p1)
    game.settle!
    game.resolve_choice!

    expect(game.choices.last.choices.to_a).not_to include(cancel, bears)
  end

  it "searches nothing when declined" do
    ResolvePermanent("Micromancer", owner: p1)
    game.settle!
    hand_size = p1.hand.count
    game.skip_choice!

    expect(p1.hand.count).to eq(hand_size)
  end
end
