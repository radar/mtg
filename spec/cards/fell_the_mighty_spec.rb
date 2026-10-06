# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FellTheMighty do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(target)
    card = Card("Fell The Mighty", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: 5)
    p1.cast(card:) { |a| a.pay_mana(generic: { white: 4 }, white: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "destroys every creature with power greater than the target's" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1) # 2
    angel = ResolvePermanent("Baneslayer Angel", owner: p2) # 5
    elves = ResolvePermanent("Llanowar Elves", owner: p2) # 1

    cast(bears)

    expect(angel.zone).not_to be_a(Magic::Zones::Battlefield)
    expect(bears.zone).to be_a(Magic::Zones::Battlefield)
    expect(elves.zone).to be_a(Magic::Zones::Battlefield)
  end

  it "spares creatures with equal power" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)

    cast(mine)

    expect(theirs.zone).to be_a(Magic::Zones::Battlefield)
  end
end
