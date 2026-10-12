# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AltanakTheThriceCalled do
  include_context "two player game"

  it "is a legendary 9/9 Insect Beast with trample" do
    altanak = ResolvePermanent("Altanak, The Thrice-Called", owner: p1)

    expect([altanak.power, altanak.toughness]).to eq([9, 9])
    expect(altanak).to be_trample
    expect(altanak.card).to be_legendary
  end

  context "when an opponent targets it" do
    let!(:altanak) { ResolvePermanent("Altanak, The Thrice-Called", owner: p1) }

    it "draws you a card" do
      p2.add_mana(red: 1)
      action = cast_action(card: Card("Lightning Bolt", owner: p2), player: p2)
      action.pay_mana(red: 1)
      action.targeting(altanak)
      game.take_action(action)
      game.settle!

      expect(p1.hand.count).to eq(8)
    end

    it "doesn't draw when you target it yourself" do
      p1.add_mana(red: 2)
      action = cast_action(card: Card("Sure Strike", owner: p1), player: p1)
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.targeting(altanak)
      game.take_action(action)
      game.settle!

      expect(p1.hand.count).to eq(7)
    end
  end

  context "from hand" do
    let!(:altanak) { Card("Altanak, The Thrice-Called", owner: p1).tap { p1.hand.add(_1) } }
    let!(:forest) { Card("Forest", owner: p1).tap { p1.graveyard.add(_1) } }
    let(:ability) { altanak.hand_abilities.first }

    before { p1.add_mana(green: 2) }

    it "discards itself to return a land from the graveyard tapped" do
      p1.activate_ability(ability: ability) do |action|
        action.targeting(forest)
        action.pay_mana(generic: { green: 1 }, green: 1)
      end
      game.stack.resolve!
      game.settle!

      land = p1.permanents.find { _1.card == forest }
      expect(land).to be_tapped
      expect(p1.graveyard.cards).to include(altanak)
      expect(p1.hand.cards).not_to include(altanak)
    end

    it "can't be activated from the battlefield" do
      permanent = ResolvePermanent("Altanak, The Thrice-Called", owner: p1)

      expect(permanent.card.hand_abilities.first.requirements_met?).to be(false)
    end
  end
end
