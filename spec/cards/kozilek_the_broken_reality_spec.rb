# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KozilekTheBrokenReality do
  include_context "two player game"

  let(:kozilek) { Card("Kozilek, The Broken Reality", owner: p1) }

  before { go_to_main_phase! }

  def empty_hand(player) = player.hand.cards.to_a.dup.each { player.hand.remove(_1) }

  def cast_kozilek
    p1.hand.add(kozilek)
    p1.add_mana(colorless: 9)
    p1.cast(card: kozilek) { |a| a.pay_mana(generic: { colorless: 9 }) }
    game.settle!
  end

  it "gives other colorless creatures you control +3/+2" do
    ResolvePermanent("Kozilek, The Broken Reality", owner: p1)
    spawn = ResolvePermanent("Spawn-Gang Commander", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!
    game.skip_choice! while game.choices.any?
    game.tick!

    expect([spawn.power, spawn.toughness]).to eq([5, 4])
    expect([bears.power, bears.toughness]).to eq([2, 2])
  end

  it "has manifested creatures get the bonus and draws a card for each manifested card" do
    empty_hand(p1)
    empty_hand(p2)
    2.times { p2.hand.add(Card("Grizzly Bears", owner: p2)) }
    cast_kozilek
    library_before = p1.library.cards.size

    game.resolve_choice!(targets: [p2])
    game.resolve_choice!(targets: p2.hand.cards.to_a)
    game.settle!

    expect(p2.creatures.size).to eq(2)
    expect(p2.hand.cards).to be_empty
    expect(p1.library.cards.size).to eq(library_before - 2)
  end

  it "lets the caster manifest from their own hand too" do
    empty_hand(p1)
    empty_hand(p2)
    2.times { p1.hand.add(Card("Grizzly Bears", owner: p1)) }
    cast_kozilek

    game.resolve_choice!(targets: [p1])
    game.resolve_choice!(targets: p1.hand.cards.to_a)
    game.settle!

    expect(p1.creatures.size).to eq(3) # Kozilek plus two manifests
    expect(p1.hand.cards.size).to eq(2)
  end
end
