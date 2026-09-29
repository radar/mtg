# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Deceit do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Deceit", owner: p1) }

  def cast(mana, payment, **options)
    p1.hand.add(card)
    p1.add_mana(mana)
    p1.cast(card:, **options) { _1.pay_mana(payment) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 5/5 Elemental Incarnation" do
    permanent = ResolvePermanent("Deceit", owner: p1, cast: false)

    expect([permanent.power, permanent.toughness]).to eq([5, 5])
  end

  describe "if {U}{U} was spent" do
    it "returns up to one other target nonland permanent to its owner's hand" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      cast({ blue: 6 }, { generic: { blue: 4 }, blue: 2 })
      game.resolve_choice!(target: bears)

      expect(bears.card.zone).to be_hand
    end

    it "may bounce nothing" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      cast({ blue: 6 }, { generic: { blue: 4 }, blue: 2 })
      game.skip_choice!

      expect(bears.zone).to be_battlefield
    end

    it "can't target itself or a land" do
      ResolvePermanent("Forest", owner: p2)
      cast({ blue: 6 }, { generic: { blue: 4 }, blue: 2 })

      expect(game.choices).to be_empty
    end
  end

  describe "if {B}{B} was spent" do
    it "has you choose a nonland card from the opponent's revealed hand to discard" do
      p2.hand.to_a.each { p2.hand.remove(_1) }
      land = Card("Forest", owner: p2)
      spell = Card("Grizzly Bears", owner: p2)
      [land, spell].each { p2.hand.add(_1) }
      cast({ black: 6 }, { generic: { black: 4 }, black: 2 })
      choice = game.choices.last

      expect(choice.choices).to eq([spell])
      game.resolve_choice!(target: spell)

      expect(spell.zone).to be_graveyard
      expect(land.zone).to be_hand
    end
  end

  describe "evoked" do
    it "is sacrificed when it enters" do
      cast({ blue: 2 }, { blue: 2 }, evoked: true)

      expect(p1.creatures.map(&:name)).not_to include("Deceit")
      expect(card.zone).to be_graveyard
    end
  end
end
