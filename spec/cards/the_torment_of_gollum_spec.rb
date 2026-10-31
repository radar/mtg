# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheTormentOfGollum do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("The Torment Of Gollum", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p2) }
  let(:forest) { Card("Forest", owner: p2) }
  let(:bolt) { Card("Shock", owner: p2) }

  def set_hand(player, *cards)
    [*player.hand.cards].each { player.hand.remove(_1) }
    cards.each { player.hand.add(_1) }
  end

  def army = p1.creatures.by_type("Army").first

  def cast_spell
    p1.hand.add(spell)
    p1.add_mana(black: 4)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { black: 3 }, black: 1).targeting(p2) }
    game.stack.resolve!
  end

  it "is a {3}{B} sorcery" do
    expect(spell.cost.cost).to eq(generic: 3, black: 1)
    expect(spell).to be_a(Magic::Cards::Sorcery)
  end

  it "reveals the opponent's hand and discards the nonland card you choose" do
    set_hand(p2, bears, forest, bolt)
    cast_spell

    expect(game.current_turn.events.find { _1.is_a?(Magic::Events::CardsRevealed) }).not_to be_nil
    choice = game.choices.last
    expect(choice.choices).to contain_exactly(bears, bolt)
    expect { choice.resolve!(card: forest) }.to raise_error(ArgumentError)

    game.resolve_choice!(card: bears)
    expect(p2.graveyard.cards).to include(bears)
    expect(p2.hand.cards).to contain_exactly(forest, bolt)
  end

  it "discards the first nonland card if the choice is skipped" do
    set_hand(p2, forest, bolt)
    cast_spell
    game.skip_choice!

    expect(p2.graveyard.cards).to include(bolt)
    expect(p2.hand.cards).to contain_exactly(forest)
  end

  it "asks nothing when the hand is all lands, but still amasses" do
    set_hand(p2, forest)
    cast_spell

    expect(game.choices).to be_empty
    expect(p2.hand.cards).to contain_exactly(forest)
    expect(army.counters.count).to eq(2)
  end

  it "amasses Orcs 2 creating a black Orc Army with two +1/+1 counters" do
    set_hand(p2, bears)
    cast_spell
    game.resolve_choice!(card: bears)
    game.settle!

    expect(army.type?("Orc")).to be(true)
    expect(army.colors).to eq([:black])
    expect([army.power, army.toughness]).to eq([2, 2])
  end

  it "adds to an existing Army instead of making a new one" do
    set_hand(p2, forest)
    first = Magic::Amass.call(source: spell, controller: p1, amount: 1, subtype: "Orc")
    game.settle!
    cast_spell
    game.settle!

    expect(p1.creatures.by_type("Army").count).to eq(1)
    expect(first.power).to eq(3)
  end

  it "only targets an opponent" do
    p1.hand.add(spell)
    p1.add_mana(black: 4)
    expect { p1.cast(card: spell) { |a| a.pay_mana(generic: { black: 3 }, black: 1).targeting(p1) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
