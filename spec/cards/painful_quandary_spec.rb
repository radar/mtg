# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PainfulQuandary do
  include_context "two player game"

  let!(:quandary) { ResolvePermanent("Painful Quandary", owner: p1) }

  def cast_shock(player, target)
    shock = Card("Shock", owner: player)
    player.hand.add(shock)
    player.add_mana(red: 1)
    player.cast(card: shock) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
    shock
  end

  it "is a {3}{B}{B} enchantment" do
    card = Card("Painful Quandary", owner: p1)
    expect(card.cost.cost).to eq(generic: 3, black: 2)
    expect(card).to be_a(Magic::Cards::Enchantment)
  end

  it "makes an opponent who casts a spell lose 5 life unless they discard a card" do
    cast_shock(p2, p1)

    expect(game.choices.last).to be_a(Magic::Choice::LoseLifeUnless)
    game.skip_choice!
    expect(p2.life).to eq(15)
  end

  it "lets them discard a card instead" do
    cast_shock(p2, p1)
    card = p2.hand.cards.first
    game.resolve_choice!(discard: card)

    expect(p2.life).to eq(20)
    expect(p2.graveyard.cards).to include(card)
  end

  it "costs the opponent the life if they have no card to discard" do
    [*p2.hand.cards].each { p2.hand.remove(_1) }
    cast_shock(p2, p1)
    game.resolve_choice!(discard: nil)

    expect(p2.life).to eq(15)
  end

  it "doesn't trigger when you cast a spell" do
    cast_shock(p1, p2)

    expect(game.choices).to be_empty
    expect(p1.life).to eq(20)
  end
end
