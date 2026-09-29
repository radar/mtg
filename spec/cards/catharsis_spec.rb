# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Catharsis do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Catharsis", owner: p1) }

  def cast(mana, payment, **options)
    p1.hand.add(card)
    p1.add_mana(mana)
    p1.cast(card:, **options) { _1.pay_mana(payment) }
    game.stack.resolve!
    game.settle!
  end

  def catharsis = p1.creatures.find { _1.name == "Catharsis" }
  def kithkin = p1.creatures.select { _1.name == "Kithkin" }

  it "is a 3/4 Elemental Incarnation" do
    permanent = ResolvePermanent("Catharsis", owner: p1, cast: false)

    expect([permanent.power, permanent.toughness]).to eq([3, 4])
  end

  it "creates two 1/1 green and white Kithkin tokens if {W}{W} was spent to cast it" do
    cast({ white: 6 }, { generic: { white: 4 }, white: 2 })

    expect(kithkin.size).to eq(2)
    expect(kithkin.first.colors).to contain_exactly(:green, :white)
    expect(catharsis).not_to be_nil
  end

  it "gives creatures you control +1/+1 and haste if {R}{R} was spent to cast it" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true)
    cast({ red: 6 }, { generic: { red: 4 }, red: 2 })
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears).to be_haste
    expect(kithkin).to be_empty
  end

  it "does both when paid with {R}{R} and {W}{W}" do
    cast({ red: 2, white: 4 }, { generic: { white: 4 }, red: 2 })

    expect(kithkin.size).to eq(2)
  end

  it "does neither when only one {R} and one {W} were spent (the generic part paid with other colours)" do
    cast({ green: 4, red: 1, white: 1 }, { generic: { green: 4 }, red: 1, white: 1 })

    expect(kithkin).to be_empty
    expect(catharsis).not_to be_nil
  end

  describe "evoked" do
    it "is sacrificed when it enters, but still triggers on the mana spent" do
      cast({ white: 2 }, { white: 2 }, evoked: true)

      expect(catharsis).to be_nil
      expect(card.zone).to be_graveyard
      expect(kithkin.size).to eq(2)
    end

    it "costs only the evoke cost" do
      p1.hand.add(card)
      p1.add_mana(white: 1)

      expect { p1.cast(card:, evoked: true) { _1.pay_mana(white: 1) } }.to raise_error(StandardError)
    end
  end
end
