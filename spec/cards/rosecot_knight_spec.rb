# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RosecotKnight do
  include_context "two player game"

  def stack_library!(*names)
    cards = names.map { Card(_1, owner: p1) }
    cards.reverse_each { p1.library.add(_1) }
    cards
  end

  def bottom(count) = p1.library.cards.last(count)

  def counters(knight) = knight.counters.of_type(Magic::Counters::Plus1Plus1).count

  def enter_knight!
    knight = ResolvePermanent("Rosecot Knight", owner: p1)
    game.settle!
    knight
  end

  it "is a 3/4 Human Knight with vigilance" do
    ring, = stack_library!("Sol Ring")
    knight = enter_knight!
    game.resolve_choice!(target: ring)

    expect([knight.power, knight.toughness]).to eq([3, 4])
    expect(knight.type?("Human")).to be(true)
    expect(knight.type?("Knight")).to be(true)
    expect(knight.keywords).to include(Magic::Cards::Keywords::VIGILANCE)
  end

  context "with an artifact and an enchantment in the top six" do
    let!(:cards) do
      stack_library!("Grizzly Bears", "Sol Ring", "Forest", "Ripples Of Undeath", "Island", "Swamp", "Plains")
    end

    it "offers only artifact and enchantment cards among the top six" do
      enter_knight!
      choice = game.choices.first

      expect(choice.choices).to contain_exactly(cards[1], cards[3])
    end

    it "takes the chosen card into hand, bottoms the rest and adds no counter" do
      knight = enter_knight!
      hand = p1.hand.count
      game.resolve_choice!(target: cards[1])
      game.settle!

      expect(cards[1].zone).to eq(p1.hand)
      expect(p1.hand.count).to eq(hand + 1)
      expect(counters(knight)).to eq(0)
      expect(bottom(5)).to contain_exactly(cards[0], cards[2], cards[3], cards[4], cards[5])
      expect(p1.library.cards.first).to eq(cards[6])
    end

    it "can take an enchantment" do
      enter_knight!
      game.resolve_choice!(target: cards[3])

      expect(cards[3].zone).to eq(p1.hand)
    end

    it "rejects a card that is not an artifact or enchantment" do
      enter_knight!

      expect { game.resolve_choice!(target: cards[0]) }.to raise_error(ArgumentError)
    end

    it "gets a +1/+1 counter when you decline, bottoming all six" do
      hand = p1.hand.count
      knight = enter_knight!
      game.skip_choice!
      game.settle!

      expect(counters(knight)).to eq(1)
      expect([knight.power, knight.toughness]).to eq([4, 5])
      expect(p1.hand.count).to eq(hand)
      expect(bottom(6)).to contain_exactly(*cards.first(6))
      expect(p1.library.cards.first).to eq(cards[6])
    end
  end

  context "with no artifact or enchantment in the top six" do
    let!(:cards) { stack_library!("Grizzly Bears", "Forest", "Island", "Swamp", "Plains", "Mountain", "Sol Ring") }

    it "asks nothing, gets the counter and bottoms the six" do
      knight = enter_knight!

      expect(game.choices).to be_empty
      expect(counters(knight)).to eq(1)
      expect(bottom(6)).to contain_exactly(*cards.first(6))
      expect(p1.library.cards.first).to eq(cards[6])
    end
  end
end
