# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LastMarchOfTheEnts do
  include_context "two player game"

  let(:march) { Card("Last March Of The Ents") }

  before do
    go_to_main_phase!
    p1.hand.add(march)
  end

  def cast_march
    p1.add_mana(green: 8)
    p1.cast(card: march) { |a| a.pay_mana(generic: { green: 6 }, green: 2) }
  end

  it "is a sorcery" do
    expect(march).to be_sorcery
  end

  it "can't be countered" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    cast_march
    spell = game.stack.first
    counterspell = Card("Counterspell", owner: p2)
    p2.hand.add(counterspell)
    p2.add_mana(blue: 2)
    p2.cast(card: counterspell) do |a|
      a.pay_mana(blue: 2)
      a.targeting(spell)
    end
    hand = p1.hand.count
    game.stack.resolve!
    game.stack.resolve!
    game.settle!

    expect(march.zone).to eq(p1.graveyard)
    expect(p1.hand.count).to eq(hand + 2)
  end

  context "when resolved" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:angel) { ResolvePermanent("Serra Angel", owner: p1) }
    let!(:ents) { 2.times.map { Card("Grizzly Bears") } }

    before { ents.each { p1.hand.add(_1) } }

    it "draws cards equal to the greatest toughness among creatures you control" do
      cast_march
      hand = p1.hand.count
      game.stack.resolve!

      expect(p1.hand.count).to eq(hand + 4)
    end

    it "draws nothing without a creature, ignoring the opponent's creatures" do
      ResolvePermanent("Serra Angel", owner: p2)
      bears.sacrifice!
      angel.sacrifice!
      game.settle!
      cast_march
      hand = p1.hand.count
      game.stack.resolve!

      expect(p1.hand.count).to eq(hand)
    end

    it "puts the chosen creature cards from hand onto the battlefield" do
      cast_march
      game.stack.resolve!
      choice = game.choices.first

      expect(choice).to be_a(described_class::PutCreatures)
      game.resolve_choice!(choices: ents)

      ents.each { expect(_1.zone).to be_battlefield }
      expect(p1.creatures.size).to eq(4)
    end

    it "does not put non-creature cards or creatures not chosen" do
      forest = p1.hand.lands.first
      cast_march
      game.stack.resolve!

      expect { game.resolve_choice!(choices: [forest]) }.to raise_error(ArgumentError)
      game.resolve_choice!(choices: [ents.first])

      expect(ents.first.zone).to be_battlefield
      expect(ents.last.zone).to eq(p1.hand)
      expect(forest.zone).to eq(p1.hand)
    end

    it "may put no creatures onto the battlefield" do
      cast_march
      game.stack.resolve!
      game.skip_choice!

      ents.each { expect(_1.zone).to eq(p1.hand) }
      expect(game.choices).to be_empty
    end
  end

  it "can't be cast on the opponent's turn" do
    game.next_turn
    expect(current_turn.active_player).to eq(p2)
    go_to_main_phase!
    p1.add_mana(green: 8)

    expect { p1.cast(card: march) { |a| a.pay_mana(generic: { green: 6 }, green: 2) } }
      .to raise_error(Magic::IllegalAction)
    expect(march.zone).to eq(p1.hand)
  end
end
