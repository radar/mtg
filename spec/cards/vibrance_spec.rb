# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Vibrance do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Vibrance", owner: p1) }

  def cast(mana, payment, **options)
    p1.hand.add(card)
    p1.add_mana(mana)
    p1.cast(card:, **options) { _1.pay_mana(payment) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/4 Elemental Incarnation" do
    permanent = ResolvePermanent("Vibrance", owner: p1, cast: false)

    expect([permanent.power, permanent.toughness]).to eq([4, 4])
  end

  it "deals 3 damage to any target if {R}{R} was spent" do
    cast({ red: 5 }, { generic: { red: 3 }, red: 2 })
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(17)
  end

  it "can deal that damage to a creature" do
    courser = ResolvePermanent("Courser Of Kruphix", owner: p2)
    cast({ red: 5 }, { generic: { red: 3 }, red: 2 })
    game.resolve_choice!(target: courser)

    expect(courser.damage).to eq(3)
  end

  describe "if {G}{G} was spent" do
    it "searches your library for a land card into your hand and gains 2 life" do
      forest = Card("Forest", owner: p1)
      p1.library.add(forest)
      cast({ green: 5 }, { generic: { green: 3 }, green: 2 })
      choice = game.choices.last
      choice.resolve!(targets: [forest])

      expect(forest.zone).to be_hand
      expect(p1.life).to eq(22)
    end
  end

  it "does neither with one {R} and one {G}" do
    cast({ blue: 3, red: 1, green: 1 }, { generic: { blue: 3 }, red: 1, green: 1 })

    expect(game.choices).to be_empty
    expect(p1.life).to eq(20)
  end

  it "is sacrificed when evoked" do
    cast({ red: 2 }, { red: 2 }, evoked: true)
    game.resolve_choice!(target: p2)

    expect(p1.creatures).to be_empty
    expect(p2.life).to eq(17)
  end
end
