# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Wistfulness do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Wistfulness", owner: p1) }

  def cast(mana, payment, **options)
    p1.hand.add(card)
    p1.add_mana(mana)
    p1.cast(card:, **options) { _1.pay_mana(payment) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 6/5 Elemental Incarnation" do
    permanent = ResolvePermanent("Wistfulness", owner: p1, cast: false)

    expect([permanent.power, permanent.toughness]).to eq([6, 5])
  end

  describe "if {G}{G} was spent" do
    it "exiles target artifact or enchantment an opponent controls" do
      stone = ResolvePermanent("Mind Stone", owner: p2)
      cast({ green: 5 }, { generic: { green: 3 }, green: 2 })

      expect(stone.card.zone).to be_exile
    end

    it "can't exile your own artifact" do
      mine = ResolvePermanent("Mind Stone", owner: p1)
      cast({ green: 5 }, { generic: { green: 3 }, green: 2 })

      expect(mine.zone).to be_battlefield
    end
  end

  describe "if {U}{U} was spent" do
    it "draws two cards, then discards a card" do
      hand = p1.hand.count
      cast({ blue: 5 }, { generic: { blue: 3 }, blue: 2 })
      choice = game.choices.last

      expect(choice).to be_a(Magic::Choice::Discard)
      game.resolve_choice!(card: p1.hand.cards.first)

      expect(p1.hand.count).to eq(hand + 1) # drew two, discarded one
    end
  end

  it "does neither with one {G} and one {U}" do
    cast({ white: 3, green: 1, blue: 1 }, { generic: { white: 3 }, green: 1, blue: 1 })

    expect(game.choices).to be_empty
  end

  it "is sacrificed when evoked" do
    cast({ blue: 2 }, { blue: 2 }, evoked: true)
    game.resolve_choice!(card: p1.hand.cards.first)

    expect(p1.creatures).to be_empty
    expect(card.zone).to be_graveyard
  end
end
