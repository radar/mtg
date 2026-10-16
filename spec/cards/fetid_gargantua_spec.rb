# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FetidGargantua do
  include_context "two player game"

  let!(:gargantua) { ResolvePermanent("Fetid Gargantua", owner: p1) }

  def adapt
    p1.add_mana(black: 3)
    p1.activate_ability(ability: gargantua.activated_abilities.first) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 4/4 Horror" do
    expect([gargantua.power, gargantua.toughness]).to eq([4, 4])
    expect(gargantua.type?("Horror")).to be(true)
  end

  context "{2}{B}: Adapt 2" do
    it "puts two +1/+1 counters on it if it has none and spends the mana" do
      adapt

      expect([gargantua.power, gargantua.toughness]).to eq([6, 6])
      expect(p1.mana_pool[:black]).to eq(0)
    end

    it "does nothing if it already has a +1/+1 counter" do
      adapt
      game.skip_choice!
      adapt

      expect(plus_counters(gargantua)).to eq(2)
      expect(game.choices).to be_empty
    end

    it "cannot be activated without paying" do
      p1.add_mana(black: 2)

      expect {
        p1.activate_ability(ability: gargantua.activated_abilities.first) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
      }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(plus_counters(gargantua)).to eq(0)
    end
  end

  context "when +1/+1 counters are put on it" do
    it "offers a may-draw once for the group of counters" do
      adapt

      expect(game.choices.count).to eq(1)
      expect(game.choices.first).to be_a(Magic::Choice::May)
    end

    it "draws two cards and loses 2 life if you accept" do
      adapt
      hand = p1.hand.count
      game.resolve_choice!
      game.settle!

      expect(p1.hand.count).to eq(hand + 2)
      expect(p1.life).to eq(18)
    end

    it "does neither if you decline" do
      adapt
      hand = p1.hand.count
      game.skip_choice!

      expect(p1.hand.count).to eq(hand)
      expect(p1.life).to eq(20)
    end

    it "triggers for a single counter placed by another effect" do
      gargantua.add_counter("+1/+1")
      game.settle!

      expect(game.choices.first).to be_a(Magic::Choice::May)
    end

    it "does not trigger for other kinds of counters" do
      gargantua.add_counter("-1/-1")
      game.settle!

      expect(game.choices).to be_empty
    end

    it "does not trigger when counters go on another creature" do
      other = ResolvePermanent("Llanowar Elves", owner: p1)
      other.add_counter("+1/+1")
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
