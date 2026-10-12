# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FeedTheSwarm do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Feed The Swarm", owner: p1).tap { p1.hand.add(_1) } }

  def cast_on(target)
    p1.add_mana(black: 2)
    p1.cast(card: spell) { _1.pay_mana(generic: { black: 1 }, black: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "destroys target creature an opponent controls and costs you life equal to its mana value" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2) # mana value 2
    cast_on(bears)

    expect(bears.zone).to be_nil
    expect(p1.life).to eq(18)
  end

  it "destroys target enchantment an opponent controls" do
    sanctum = ResolvePermanent("Sanctum Of Calm Waters", owner: p2) # mana value 4
    cast_on(sanctum)

    expect(sanctum.zone).to be_nil
    expect(p1.life).to eq(16)
  end

  it "only targets permanents an opponent controls" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Forest", owner: p2)

    expect(spell.target_choices).to eq([theirs])
    expect(spell.target_choices).not_to include(mine)
  end
end
