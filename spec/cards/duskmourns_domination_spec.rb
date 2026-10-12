# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DuskmournsDomination do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Duskmourn's Domination", owner: p1) }
  let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p2) }

  def enchant(target)
    p1.add_mana(blue: 6)
    p1.cast(card: card) do
      _1.pay_mana(generic: { blue: 4 }, blue: 2)
      _1.targeting(target)
    end
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "can target any creature, including an opponent's" do
    expect(card.target_choices).to include(angel)
  end

  context "once attached" do
    before { enchant(angel) }

    it "gives you control of the creature" do
      expect(p1.creatures).to include(angel)
      expect(p2.creatures).not_to include(angel)
    end

    it "gives it -3/-0" do
      expect(angel.power).to eq(2)
      expect(angel.toughness).to eq(5)
    end

    it "makes it lose all abilities" do
      expect(angel.has_keyword?(Magic::Cards::Keywords::FLYING)).to be false
      expect(angel.has_keyword?(Magic::Cards::Keywords::LIFELINK)).to be false
    end
  end
end
