# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DreamdrinkerVampire do
  include_context "two player game"

  let!(:vampire) { ResolvePermanent("Dreamdrinker Vampire", owner: p1) }

  def adapt
    p1.add_mana(black: 2)
    p1.activate_ability(ability: vampire.activated_abilities.first) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  def plus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Plus1Plus1).count

  it "is a 2/1 Vampire with lifelink" do
    expect([vampire.power, vampire.toughness]).to eq([2, 1])
    expect(vampire.type?("Vampire")).to be(true)
    expect(vampire).to have_keyword(:lifelink)
  end

  context "{1}{B}: Adapt 1" do
    it "puts a +1/+1 counter on it if it has none and spends the mana" do
      adapt

      expect([vampire.power, vampire.toughness]).to eq([3, 2])
      expect(p1.mana_pool[:black]).to eq(0)
    end

    it "does nothing if it already has a +1/+1 counter" do
      adapt
      adapt

      expect(plus_counters(vampire)).to eq(1)
    end

    it "cannot be activated without paying" do
      p1.add_mana(black: 1)

      expect {
        p1.activate_ability(ability: vampire.activated_abilities.first) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
      }.to raise_error(Magic::Costs::Mana::CannotPay)
      expect(plus_counters(vampire)).to eq(0)
    end
  end

  context "when +1/+1 counters are put on it" do
    it "has no menace beforehand" do
      expect(vampire).not_to have_keyword(:menace)
    end

    it "gains menace" do
      adapt
      game.tick!

      expect(vampire).to have_keyword(:menace)
    end

    it "loses menace at end of turn" do
      adapt
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(vampire).not_to have_keyword(:menace)
    end

    it "gains menace for a counter placed by another effect" do
      vampire.add_counter("+1/+1")
      game.settle!
      game.tick!

      expect(vampire).to have_keyword(:menace)
    end

    it "does not gain menace from other kinds of counters" do
      vampire.add_counter("-1/-1")
      game.settle!
      game.tick!

      expect(vampire).not_to have_keyword(:menace)
    end

    it "does not gain menace when counters go on another creature" do
      other = ResolvePermanent("Llanowar Elves", owner: p1)
      other.add_counter("+1/+1")
      game.settle!
      game.tick!

      expect(vampire).not_to have_keyword(:menace)
    end
  end
end
