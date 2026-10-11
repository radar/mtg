# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OverlordOfTheMistmoors do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Overlord Of The Mistmoors", owner: p1).tap { p1.hand.add(_1) } }

  def insects = p1.creatures.select { _1.type?("Insect") }
  def overlord = p1.permanents.find { _1.card == card }

  def cast_impending!
    p1.add_mana(white: 4)
    p1.cast_as(:impending, card: card) { _1.pay_mana(generic: { white: 2 }, white: 2) }
    game.stack.resolve!
    game.settle!
  end

  def cast_normally!
    p1.add_mana(white: 7)
    p1.cast(card: card) { _1.pay_mana(generic: { white: 5 }, white: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 6/6 Avatar Horror enchantment creature" do
    cast_normally!

    expect([overlord.power, overlord.toughness]).to eq([6, 6])
    expect(overlord).to be_creature
    expect(overlord.card).to be_enchantment
    expect(overlord.type?("Avatar")).to be(true)
  end

  it "creates two 2/1 flying Insects when it enters" do
    cast_normally!

    expect(insects.size).to eq(2)
    expect([insects.first.power, insects.first.toughness]).to eq([2, 1])
    expect(insects.first).to have_keyword(:flying)
    expect(insects.first.colors).to eq([:white])
  end

  describe "cast for its impending cost" do
    it "costs {2}{W}{W}" do
      p1.add_mana(white: 3)

      expect { p1.cast_as(:impending, card: card) { _1.pay_mana(generic: { white: 1 }, white: 2) } }
        .to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "enters with four time counters and isn't a creature, but its enters trigger still happens" do
      cast_impending!

      expect(overlord.counters.of_type(Magic::Counters::Time).count).to eq(4)
      expect(overlord).not_to be_creature
      expect(overlord.card).to be_enchantment
      expect(insects.size).to eq(2)
    end

    it "loses a time counter at the beginning of its controller's end step" do
      cast_impending!
      current_turn.end!
      game.settle!

      expect(overlord.counters.of_type(Magic::Counters::Time).count).to eq(3)
    end

    it "doesn't lose a time counter at an opponent's end step" do
      cast_impending!
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      game.next_turn
      go_to_main_phase!
      current_turn.end!
      game.settle!

      expect(overlord.counters.of_type(Magic::Counters::Time).count).to eq(3)
    end

    it "becomes a creature when the last time counter is removed" do
      cast_impending!
      overlord.remove_counter(counter_type: Magic::Counters::Time, amount: 4)
      game.tick!

      expect(overlord).to be_creature
      expect([overlord.power, overlord.toughness]).to eq([6, 6])
    end

    it "is offered as a legal action when affordable" do
      card # in hand
      p1.add_mana(white: 4)

      expect(game.legal_actions(p1).grep(Magic::Actions::Cast::Impending).map(&:card)).to eq([card])
    end
  end
end
