# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RakdosLordOfRiots do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:rakdos) { Card("Rakdos Lord Of Riots", owner: p1).tap { p1.hand.add(_1) } }

  def cast_rakdos!
    p1.add_mana(black: 2, red: 2)
    p1.cast(card: rakdos) { _1.pay_mana(black: 2, red: 2) }
    game.stack.resolve!
  end

  it "has flying and trample" do
    permanent = ResolvePermanent("Rakdos Lord Of Riots", owner: p1)

    expect(permanent).to have_keyword(:flying)
    expect(permanent).to have_keyword(:trample)
  end

  it "can't be cast unless an opponent lost life this turn" do
    p1.add_mana(black: 2, red: 2)

    expect { p1.cast(card: rakdos) { _1.pay_mana(black: 2, red: 2) } }.to raise_error(Magic::IllegalAction)
    expect(rakdos.zone).to be_hand
  end

  it "can be cast once an opponent lost life" do
    p2.lose_life(1)
    cast_rakdos!

    expect(p1.creatures.map(&:name)).to include("Rakdos, Lord of Riots")
  end

  it "doesn't count your own life loss" do
    p1.lose_life(3)
    p1.add_mana(black: 2, red: 2)

    expect { p1.cast(card: rakdos) { _1.pay_mana(black: 2, red: 2) } }.to raise_error(Magic::IllegalAction)
  end

  describe "the cost reduction" do
    before { ResolvePermanent("Rakdos Lord Of Riots", owner: p1) }

    let(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.hand.add(_1) } }

    it "makes creature spells cost {1} less per life the opponents lost this turn" do
      p2.lose_life(1)
      p1.add_mana(green: 1)
      p1.cast(card: bears) { _1.pay_mana(green: 1) }
      game.stack.resolve!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "doesn't reduce coloured mana" do
      p2.lose_life(5)
      p1.add_mana(red: 1)

      expect { p1.cast(card: bears) { _1.pay_mana(red: 1) } }.to raise_error(StandardError)
    end

    it "costs full price when no life was lost" do
      p1.add_mana(green: 1)

      expect { p1.cast(card: bears) { _1.pay_mana(green: 1) } }.to raise_error(StandardError)
    end
  end
end
