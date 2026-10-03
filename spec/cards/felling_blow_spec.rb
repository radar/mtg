# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FellingBlow do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Erudite Wizard", owner: p2) } # 2/3: dies only to the boosted bear
  let(:spell) { Card("Felling Blow", owner: p1) }

  def cast_blow(biter, victim)
    p1.hand.add(spell)
    p1.add_mana(green: 3)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1).targeting(biter, victim) }
    game.stack.resolve!
    game.tick!
  end

  it "is a {2}{G} sorcery" do
    expect(spell.cost.cost).to eq(generic: 2, green: 1)
    expect(spell).to be_a(Magic::Cards::Sorcery)
  end

  it "puts a +1/+1 counter on your creature first, then it deals damage equal to its new power" do
    cast_blow(mine, theirs)

    expect(mine.power).to eq(3)
    expect(p2.graveyard.cards.map(&:name)).to include("Erudite Wizard")
  end

  it "deals damage one way only" do
    cast_blow(mine, theirs)

    expect(mine.damage).to eq(0)
  end

  it "keeps the counter even if the victim survives" do
    big = ResolvePermanent("Serra Angel", owner: p2)
    cast_blow(mine, big)

    expect(mine.power).to eq(3)
    expect(big.damage).to eq(3)
    expect(big.zone).to be_battlefield
  end

  it "can't use an opponent's creature as the one that deals damage" do
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    expect { p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1).targeting(theirs, mine) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't target your own creature as the one it damages" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)

    expect { p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 2 }, green: 1).targeting(mine, other) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
