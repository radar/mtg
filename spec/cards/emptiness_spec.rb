# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Emptiness do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Emptiness", owner: p1) }

  def cast(mana, payment, **options)
    p1.hand.add(card)
    p1.add_mana(mana)
    p1.cast(card:, **options) { _1.pay_mana(payment) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 3/5 Elemental Incarnation" do
    permanent = ResolvePermanent("Emptiness", owner: p1, cast: false)

    expect([permanent.power, permanent.toughness]).to eq([3, 5])
  end

  describe "if {W}{W} was spent" do
    it "returns a creature card with mana value 3 or less from your graveyard to the battlefield" do
      bears = Card("Grizzly Bears", owner: p1)
      p1.graveyard.add(bears)
      cast({ white: 6 }, { generic: { white: 4 }, white: 2 })

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "can't return a creature card with mana value 4 or more" do
      p1.graveyard.add(Card("Sunderflock", owner: p1))
      cast({ white: 6 }, { generic: { white: 4 }, white: 2 })

      expect(p1.creatures.map(&:name)).to eq(["Emptiness"])
    end
  end

  describe "if {B}{B} was spent" do
    it "puts three -1/-1 counters on up to one target creature" do
      courser = ResolvePermanent("Courser Of Kruphix", owner: p2)
      cast({ black: 6 }, { generic: { black: 4 }, black: 2 })
      game.resolve_choice!(target: courser)

      expect(courser.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(3)
    end

    it "may target nothing" do
      courser = ResolvePermanent("Courser Of Kruphix", owner: p2)
      cast({ black: 6 }, { generic: { black: 4 }, black: 2 })
      game.skip_choice!

      expect(courser.counters.of_type(Magic::Counters::Minus1Minus1)).to be_empty
    end
  end

  it "does neither when it wasn't paid with {W}{W} or {B}{B}" do
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    cast({ green: 4, white: 1, black: 1 }, { generic: { green: 4 }, white: 1, black: 1 })

    expect(p1.creatures.map(&:name)).to eq(["Emptiness"])
  end

  it "is sacrificed when evoked, and its triggers still use the mana spent" do
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    cast({ white: 2 }, { white: 2 }, evoked: true)

    expect(p1.creatures.map(&:name)).to eq(["Grizzly Bears"])
    expect(card.zone).to be_graveyard
  end
end
