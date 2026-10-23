# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AnnoyedAltisaur do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:altisaur) { Card("Annoyed Altisaur", owner: p1).tap { p1.hand.add(_1) } }

  def cast_altisaur
    p1.add_mana(green: 7)
    p1.cast(card: altisaur) { |action| action.pay_mana(green: 2, generic: { green: 5 }) }
  end

  it "has reach and trample" do
    permanent = ResolvePermanent("Annoyed Altisaur", owner: p1)
    expect(permanent.keywords).to include(Magic::Cards::Keywords::REACH, Magic::Cards::Keywords::TRAMPLE)
  end

  context "cascade" do
    let(:land) { Card("Forest", owner: p1) }
    let(:cheap) { Card("Grizzly Bears", owner: p1) }
    let(:expensive) { Card("Annoyed Altisaur", owner: p1) }

    it "exiles until a cheaper nonland card, casts it free, and bottoms the rest" do
      p1.library.add(cheap)
      p1.library.add(land)
      p1.library.add(expensive)

      cast_altisaur
      game.settle!

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears", "Annoyed Altisaur")
      expect(p1.library.cards.last(2)).to contain_exactly(land, expensive)
    end
  end
end
