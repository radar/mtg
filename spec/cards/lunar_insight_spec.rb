# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LunarInsight do
  include_context "two player game"

  let(:spell) { Card("Lunar Insight", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(spell)
  end

  def cast_insight
    p1.add_mana(blue: 3)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
  end

  it "is a {2}{U} sorcery" do
    expect(spell.cost.cost).to eq(generic: 2, blue: 1)
    expect(spell).to be_a(Magic::Cards::Sorcery)
  end

  it "draws a card for each different mana value among your nonland permanents" do
    ResolvePermanent("Grizzly Bears", owner: p1)  # mana value 2
    ResolvePermanent("Savannah Lions", owner: p1) # mana value 1

    expect { cast_insight }.to change { p1.hand.count }.by(2 - 1) # two cards drawn, the spell leaves the hand
  end

  it "counts each mana value once" do
    2.times { ResolvePermanent("Grizzly Bears", owner: p1) }

    expect { cast_insight }.to change { p1.hand.count }.by(1 - 1)
  end

  it "ignores lands and your opponent's permanents" do
    ResolvePermanent("Forest", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)

    expect { cast_insight }.to change { p1.hand.count }.by(0 - 1)
  end
end
