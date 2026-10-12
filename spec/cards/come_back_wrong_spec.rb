# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ComeBackWrong do
  include_context "two player game"

  let(:spell) { Card("Come Back Wrong", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(spell)
    p1.add_mana(black: 1, green: 2)
  end

  def cast_on(target)
    p1.cast(card: spell) do |action|
      action.pay_mana(generic: { green: 2 }, black: 1)
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  it "destroys the creature and returns it under your control" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_on(bear)

    expect(p2.creatures.map(&:name)).not_to include("Grizzly Bears")
    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "sacrifices the returned creature at the beginning of the next end step" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_on(bear)

    current_turn.end!
    game.settle!

    expect(p1.creatures.map(&:name)).not_to include("Grizzly Bears")
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "does not return an indestructible creature" do
    golem = ResolvePermanent("Darksteel Colossus", owner: p2)
    cast_on(golem)

    expect(p2.creatures).to include(golem)
    expect(p1.creatures).to be_empty
  end
end
