# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FangsOfKalonia do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:their_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  let(:fangs) { Card("Fangs of Kalonia", owner: p1).tap { p1.hand.add(_1) } }

  it "puts a +1/+1 counter on target creature you control, then doubles them" do
    p1.add_mana(green: 2)
    p1.cast(card: fangs) do |action|
      action.pay_mana(green: 1, generic: { green: 1 })
      action.targeting(bears)
    end
    game.stack.resolve!

    expect(counters(bears)).to eq(2)
    expect(counters(other_bears)).to eq(0)
  end

  it "doubles counters already on the creature" do
    bears.add_counter("+1/+1", amount: 2)
    p1.add_mana(green: 2)
    p1.cast(card: fangs) do |action|
      action.pay_mana(green: 1, generic: { green: 1 })
      action.targeting(bears)
    end
    game.stack.resolve!

    expect(counters(bears)).to eq(6)
  end

  it "cannot target an opponent's creature" do
    p1.add_mana(green: 2)
    expect do
      p1.cast(card: fangs) do |action|
        action.pay_mana(green: 1, generic: { green: 1 })
        action.targeting(their_bears)
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  context "overloaded" do
    it "affects each creature you control, and none of the opponent's, for {4}{G}{G}" do
      p1.add_mana(green: 6)
      p1.cast_as(:overloaded, card: fangs) { |action| action.pay_mana(green: 2, generic: { green: 4 }) }
      game.stack.resolve!

      expect(counters(bears)).to eq(2)
      expect(counters(other_bears)).to eq(2)
      expect(counters(their_bears)).to eq(0)
    end
  end
end
