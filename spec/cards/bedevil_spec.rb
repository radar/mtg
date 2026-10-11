# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Bedevil do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Bedevil", owner: p1).tap { p1.hand.add(_1) } }

  def cast_on(target)
    p1.add_mana(black: 2, red: 1)
    p1.cast(card: spell) { _1.pay_mana(black: 2, red: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "destroys target creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_on(bears)

    expect(bears.zone).to be_nil
  end

  it "destroys target artifact" do
    ring = ResolvePermanent("Sol Ring", owner: p2)
    cast_on(ring)

    expect(ring.zone).to be_nil
  end

  it "destroys target planeswalker" do
    walker = ResolvePermanent("Garruk Unleashed", owner: p2)
    cast_on(walker)

    expect(walker.zone).to be_nil
  end

  it "can't target a land or an enchantment" do
    land = ResolvePermanent("Forest", owner: p2)

    expect(spell.target_choices).not_to include(land)
  end
end
