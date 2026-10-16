# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CursedWombat do
  include_context "two player game"

  let!(:wombat) { ResolvePermanent("Cursed Wombat", owner: p1) }

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  def adapt
    p1.add_mana(black: 2, green: 2)
    p1.activate_ability(ability: wombat.activated_abilities.first) { |a| a.pay_mana(generic: { black: 1, green: 1 }, black: 1, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  # Puts a +1/+1 counter on the permanent through the effect, as a spell or ability would.
  def put_counter(permanent, amount: 1)
    permanent.add_counter("+1/+1", amount: amount)
    game.settle!
  end

  it "is a 2/3 Nightmare Wombat" do
    expect([wombat.power, wombat.toughness]).to eq([2, 3])
    expect(wombat.type?("Wombat")).to be(true)
  end

  context "{2}{B}{G}: Adapt 2" do
    it "puts counters on it if it has none, plus the additional counter (2 + 1)" do
      adapt

      expect(plus_counters(wombat)).to eq(3)
      expect(p1.mana_pool[:black]).to eq(0)
    end

    it "does nothing if it already has a +1/+1 counter" do
      adapt
      adapt

      expect(plus_counters(wombat)).to eq(3)
    end

    it "cannot be activated without enough mana" do
      p1.add_mana(black: 1, green: 1)

      expect {
        p1.activate_ability(ability: wombat.activated_abilities.first) { |a| a.pay_mana(generic: { black: 1, green: 1 }, black: 1, green: 1) }
      }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(plus_counters(wombat)).to eq(0)
    end
  end

  context "permanents you control have the additional-counter trigger" do
    it "adds an additional counter to another permanent you control" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      put_counter(bears)

      expect(plus_counters(bears)).to eq(2)
    end

    it "adds just one additional counter when several are put on at once" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      put_counter(bears, amount: 3)

      expect(plus_counters(bears)).to eq(4)
    end

    it "triggers only once each turn for each permanent" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      put_counter(bears)
      put_counter(bears)

      expect(plus_counters(bears)).to eq(3)
    end

    it "triggers again on a later turn" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      put_counter(bears)
      current_turn.end!
      current_turn.cleanup!
      game.next_turn
      put_counter(bears)

      expect(plus_counters(bears)).to eq(4)
    end

    it "tracks each permanent separately" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      elves = ResolvePermanent("Llanowar Elves", owner: p1)
      put_counter(bears)
      put_counter(elves)

      expect(plus_counters(bears)).to eq(2)
      expect(plus_counters(elves)).to eq(2)
    end

    it "does not affect an opponent's permanents" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      put_counter(theirs)

      expect(plus_counters(theirs)).to eq(1)
    end

    it "does not trigger for other kinds of counters" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      bears.add_counter("-1/-1")
      game.settle!

      expect(plus_counters(bears)).to eq(0)
    end

    it "stops working once the Wombat leaves the battlefield" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      wombat.destroy!
      game.settle!
      put_counter(bears)

      expect(plus_counters(bears)).to eq(1)
    end
  end
end
