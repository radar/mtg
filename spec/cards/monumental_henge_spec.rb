# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MonumentalHenge do
  include_context "two player game"

  def stack_library!(*names)
    cards = names.map { Card(_1, owner: p1) }
    cards.reverse_each { p1.library.add(_1) }
    cards
  end

  def bottom(count) = p1.library.cards.last(count)

  describe "entering" do
    it "enters tapped unless you control a Plains" do
      henge = ResolvePermanent("Monumental Henge", owner: p1)

      expect(henge).to be_tapped
    end

    it "enters untapped if you control a Plains" do
      ResolvePermanent("Plains", owner: p1)
      henge = ResolvePermanent("Monumental Henge", owner: p1)

      expect(henge).not_to be_tapped
    end

    it "does not count an opponent's Plains" do
      ResolvePermanent("Plains", owner: p2)
      henge = ResolvePermanent("Monumental Henge", owner: p1)

      expect(henge).to be_tapped
    end
  end

  describe "{T}: Add {W}" do
    it "adds white mana" do
      ResolvePermanent("Plains", owner: p1)
      henge = ResolvePermanent("Monumental Henge", owner: p1)
      p1.activate_ability(ability: henge.activated_abilities.first)

      expect(p1.mana_pool[:white]).to eq(1)
      expect(henge).to be_tapped
    end
  end

  describe "{2}{W}{W}, {T}: look at the top five" do
    let!(:plains) { ResolvePermanent("Plains", owner: p1) }
    let!(:henge) { ResolvePermanent("Monumental Henge", owner: p1) }
    let!(:cards) do
      stack_library!("Fable Of The Mirror Breaker", "Rosheen, Roaring Prophet", "Sol Ring", "Grizzly Bears", "Forest", "Island")
    end

    def activate!(who: p1)
      who.add_mana(white: 4)
      who.activate_ability(ability: henge.activated_abilities.last) { |a| a.pay_mana(generic: { white: 2 }, white: 2) }
      game.stack.resolve!
    end

    it "offers only historic cards (Saga, legendary, artifact) among the top five" do
      activate!
      choice = game.choices.first

      expect(choice.choices).to contain_exactly(cards[0], cards[1], cards[2])
      expect(choice.choices).not_to include(cards[3], cards[4], cards[5])
    end

    it "pays {2}{W}{W} and taps the land" do
      activate!

      expect(p1.mana_pool[:white]).to eq(0)
      expect(henge).to be_tapped
    end

    it "puts the chosen historic card into hand and the rest of the five on the bottom" do
      activate!
      game.resolve_choice!(target: cards[2])

      expect(cards[2].zone).to eq(p1.hand)
      expect(bottom(4)).to contain_exactly(cards[0], cards[1], cards[3], cards[4])
      expect(p1.library.cards.first).to eq(cards[5])
    end

    it "rejects a non-historic card" do
      activate!

      expect { game.resolve_choice!(target: cards[3]) }.to raise_error(ArgumentError)
    end

    it "rejects the sixth card even if it were historic" do
      activate!

      expect { game.resolve_choice!(target: cards[5]) }.to raise_error(ArgumentError)
    end

    it "puts all five on the bottom when you decline" do
      hand = p1.hand.count
      activate!
      game.skip_choice!

      expect(p1.hand.count).to eq(hand)
      expect(bottom(5)).to contain_exactly(*cards.first(5))
      expect(p1.library.cards.first).to eq(cards[5])
    end

    it "cannot be paid for with too little mana" do
      p1.add_mana(white: 3)

      expect { p1.activate_ability(ability: henge.activated_abilities.last) { |a| a.pay_mana(generic: { white: 2 }, white: 2) } }
        .to raise_error(Magic::Costs::Mana::CannotPay)
      expect(game.choices).to be_empty
      expect(p1.library.cards.first).to eq(cards[0])
    end

    it "cannot be activated by an opponent" do
      p2.add_mana(white: 4)

      expect { p2.activate_ability(ability: henge.activated_abilities.last) { |a| a } }
        .to raise_error(Magic::IllegalAction, /does not control/)
      expect(p2.mana_pool[:white]).to eq(4)
      expect(henge).not_to be_tapped
      expect(game.choices).to be_empty
      expect(p1.library.cards.first).to eq(cards[0])
    end
  end

  describe "with no historic card in the top five" do
    before { ResolvePermanent("Plains", owner: p1) }

    let!(:henge) { ResolvePermanent("Monumental Henge", owner: p1) }
    let!(:cards) { stack_library!("Grizzly Bears", "Forest", "Island", "Swamp", "Mountain", "Plains") }

    it "asks nothing and bottoms the five" do
      p1.add_mana(white: 4)
      p1.activate_ability(ability: henge.activated_abilities.last) { |a| a.pay_mana(generic: { white: 2 }, white: 2) }
      game.stack.resolve!

      expect(game.choices).to be_empty
      expect(bottom(5)).to contain_exactly(*cards.first(5))
      expect(p1.library.cards.first).to eq(cards[5])
    end
  end
end
