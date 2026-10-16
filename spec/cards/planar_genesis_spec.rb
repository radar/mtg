# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PlanarGenesis do
  include_context "two player game"

  def stack_library!(*names)
    cards = names.map { Card(_1, owner: p1) }
    cards.reverse_each { p1.library.add(_1) }
    cards
  end

  def cast!
    genesis = Card("Planar Genesis", owner: p1)
    p1.hand.add(genesis)
    p1.add_mana(green: 1, blue: 1)
    p1.cast(card: genesis) { |a| a.pay_mana(green: 1, blue: 1) }
    game.stack.resolve!
  end

  def bottom(count) = p1.library.cards.last(count)

  let!(:cards) { stack_library!("Forest", "Island", "Grizzly Bears", "Sol Ring", "Plains") }
  let(:forest) { cards[0] }
  let(:island) { cards[1] }
  let(:bears) { cards[2] }
  let(:ring) { cards[3] }
  let(:plains) { cards[4] }

  it "offers only the land cards among the top four to put onto the battlefield" do
    cast!
    choice = game.choices.first

    expect(choice.choices).to contain_exactly(forest, island)
    expect(choice.choices).not_to include(bears, ring, plains)
  end

  it "puts a land onto the battlefield tapped and the rest on the bottom, with nothing going to hand" do
    hand = p1.hand.count
    cast!
    game.resolve_choice!(target: island)
    game.settle!

    permanent = p1.permanents.find { _1.card == island }
    expect(permanent).to be_tapped
    expect(p1.hand.count).to eq(hand)
    expect(game.choices).to be_empty
    expect(bottom(3)).to contain_exactly(forest, bears, ring)
    expect(p1.library.cards.first).to eq(plains)
  end

  it "rejects a card that is not a land among the top four" do
    cast!

    expect { game.resolve_choice!(target: bears) }.to raise_error(ArgumentError)
  end

  it "if you don't, puts any card from among them into your hand" do
    cast!
    game.skip_choice!
    hand_choice = game.choices.first

    expect(hand_choice.choices).to contain_exactly(forest, island, bears, ring)
    game.resolve_choice!(target: ring)

    expect(ring.zone).to eq(p1.hand)
    expect(p1.permanents.map(&:card)).not_to include(forest, island)
    expect(bottom(3)).to contain_exactly(forest, island, bears)
    expect(p1.library.cards.first).to eq(plains)
  end

  it "can put a land into hand when you decline to put it onto the battlefield" do
    cast!
    game.skip_choice!
    game.resolve_choice!(target: forest)

    expect(forest.zone).to eq(p1.hand)
  end

  it "does not allow taking the fifth card into hand" do
    cast!
    game.skip_choice!

    expect { game.resolve_choice!(target: plains) }.to raise_error(ArgumentError)
  end

  context "with no land among the top four" do
    let!(:cards) { stack_library!("Grizzly Bears", "Sol Ring", "Llanowar Elves", "Mind Stone", "Forest") }

    it "goes straight to choosing a card for your hand" do
      cast!
      choice = game.choices.first
      expect(choice).to be_a(Magic::Cards::PlanarGenesis::HandChoice)

      game.resolve_choice!(target: cards[2])

      expect(cards[2].zone).to eq(p1.hand)
      expect(bottom(3)).to contain_exactly(cards[0], cards[1], cards[3])
      expect(p1.library.cards.first).to eq(cards[4])
    end
  end
end
