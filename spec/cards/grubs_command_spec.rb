# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrubsCommand do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:command) { Card("Grubs Command", owner: p1) }

  def cast_with(*modes)
    p1.hand.add(command)
    p1.add_mana(black: 4, red: 1)
    p1.cast(card: command) do |action|
      action.pay_mana(black: 1, red: 1, generic: { black: 3 })
      modes.each { |mode, *targets| action.choose_mode(mode) { _1.targeting(*targets) } }
    end
    game.stack.resolve!
    game.tick!
  end

  it "copies a Goblin you control and destroys a creature" do
    goblin = ResolvePermanent("Boggart Prankster", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_with([described_class::CopyGoblin, goblin], [described_class::Destroy, bears])

    expect(p1.creatures.count { _1.name == "Boggart Prankster" }).to eq(2)
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "gives a player's creatures +1/+1 and haste, and destroys an artifact" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    stone = ResolvePermanent("Mind Stone", owner: p2)
    cast_with([described_class::Buff, p1], [described_class::Destroy, stone])

    expect(bears.power).to eq(3)
    expect(bears.haste?).to eq(true)
    expect(p2.graveyard.cards.map(&:name)).to include("Mind Stone")
  end

  it "mills five and puts milled Goblin cards into hand" do
    goblins = 2.times.map { Card("Boggart Prankster", owner: p2) }
    others = 3.times.map { Card("Forest", owner: p2) }
    [*goblins, *others].reverse_each { p2.library.add(_1) }
    cast_with([described_class::Mill, p2], [described_class::Buff, p1])

    expect(p2.hand.cards).to include(*goblins)
    expect(p2.graveyard.cards).to include(*others)
  end
end
