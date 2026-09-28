# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Sunderflock do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Sunderflock", owner: p1) }

  it "costs {X} less, where X is the greatest mana value among your Elementals" do
    ResolvePermanent("Shinestriker", owner: p1) # mana value 6
    p1.add_mana(blue: 3)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 1 }, blue: 2) }
    game.stack.resolve!

    expect(card.zone).to be_battlefield
  end

  it "returns all non-Elemental creatures to their owners' hands when cast" do
    ResolvePermanent("Shinestriker", owner: p1)
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    their_bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(blue: 3)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 1 }, blue: 2) }
    game.stack.resolve!
    game.settle!

    expect(own_bears.card.zone).to be_hand
    expect(their_bears.card.zone).to be_hand
    expect(p1.creatures.map(&:name)).to contain_exactly("Shinestriker", "Sunderflock")
  end

  it "does nothing when it enters without being cast" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Sunderflock", owner: p1, cast: false)

    expect(bears.zone).to be_battlefield
  end
end
