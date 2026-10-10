# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DragToTheRoots do
  include_context "two player game"

  let(:card) { Card("Drag To The Roots", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { p1.hand.add(card) }

  def fill_graveyard!
    %w[Grizzly\ Bears Island Lightning\ Bolt Cultivate].each { p1.graveyard.add(Card(_1, owner: p1)) }
  end

  it "destroys target nonland permanent for {2}{B}{G}" do
    p1.add_mana(black: 1, green: 1, red: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 2 }, black: 1, green: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "cannot target a land" do
    island = ResolvePermanent("Island", owner: p2)

    expect(card.target_choices).to include(bears)
    expect(card.target_choices).not_to include(island)
  end

  it "costs {2} less with delirium" do
    fill_graveyard!
    expect(p1.graveyard).to be_delirium

    p1.add_mana(black: 1, green: 1)
    p1.cast(card:) { |a| a.pay_mana(black: 1, green: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "costs full price without delirium" do
    p1.add_mana(black: 1, green: 1)

    expect { p1.cast(card:) { |a| a.pay_mana(black: 1, green: 1).targeting(bears) } }.to raise_error(StandardError)
  end
end
