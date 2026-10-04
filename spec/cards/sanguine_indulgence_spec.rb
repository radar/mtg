# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SanguineIndulgence do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:indulgence) { Card("Sanguine Indulgence", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }
  let(:ghoul) { Card("Diregraf Ghoul", owner: p1) }
  let(:third) { Card("Elvish Regrower", owner: p1) }
  let(:bolt) { Card("Boltwave", owner: p1) }

  before { p1.hand.add(indulgence) }

  it "returns up to two creature cards from your graveyard to your hand" do
    [bears, ghoul, third].each { p1.graveyard.add(_1) }
    p1.add_mana(black: 4)
    cast_and_resolve(card: indulgence) do |a|
      a.targeting(bears, ghoul)
      a.pay_mana(black: 1, generic: { black: 3 })
    end

    expect([bears, ghoul].map(&:zone)).to all(be_hand)
    expect(third.zone).to be_graveyard
  end

  it "can return just one card" do
    p1.graveyard.add(bears)
    p1.add_mana(black: 4)
    cast_and_resolve(card: indulgence) do |a|
      a.targeting(bears)
      a.pay_mana(black: 1, generic: { black: 3 })
    end

    expect(bears.zone).to be_hand
  end

  it "can't target a noncreature card" do
    p1.graveyard.add(bolt)

    expect { cast_action(card: indulgence, targeting: bolt) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  describe "the cost reduction" do
    it "costs {3}{B} if you haven't gained 3 life this turn" do
      p1.add_mana(black: 1)

      expect(cast_action(card: indulgence)).not_to be_can_perform
    end

    it "costs {B} if you've gained 3 or more life this turn" do
      p1.gain_life(3)
      p1.add_mana(black: 1)

      expect(cast_action(card: indulgence)).to be_can_perform
    end

    it "costs {B} if the life was gained in several chunks" do
      p1.gain_life(1)
      p1.gain_life(2)
      p1.add_mana(black: 1)

      expect(cast_action(card: indulgence)).to be_can_perform
    end

    it "doesn't discount for less than 3 life, or for an opponent's life gain" do
      p1.gain_life(2)
      p2.gain_life(5)
      p1.add_mana(black: 1)

      expect(cast_action(card: indulgence)).not_to be_can_perform
    end

    it "casts for just {B} after gaining the life" do
      p1.graveyard.add(bears)
      p1.gain_life(3)
      p1.add_mana(black: 1)
      cast_and_resolve(card: indulgence) do |a|
        a.targeting(bears)
        a.pay_mana(black: 1)
      end

      expect(bears.zone).to be_hand
    end
  end
end
