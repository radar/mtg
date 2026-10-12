# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ImpossibleInferno do
  include_context "two player game"

  let(:card) { Card("Impossible Inferno", owner: p1) }
  let!(:giant) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { p1.hand.add(card) }

  def fill_graveyard!
    %w[Grizzly\ Bears Island Lightning\ Bolt Cultivate].each { p1.graveyard.add(Card(_1, owner: p1)) }
  end

  def cast!
    p1.add_mana(red: 5)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 4 }, red: 1).targeting(giant) }
    game.stack.resolve!
    game.settle!
  end

  it "deals 6 damage to target creature" do
    cast!

    expect(giant).to be_dead
  end

  it "only targets creatures" do
    land = ResolvePermanent("Island", owner: p2)

    expect(card.target_choices).to include(giant)
    expect(card.target_choices).not_to include(land)
  end

  it "doesn't exile the top card without delirium" do
    top = p1.library.first
    cast!

    expect(top.zone).to be_library
    expect(game.play_permissions.permits?(top, p1)).to be(false)
  end

  it "with delirium exiles the top card and lets you play it until the end of your next turn" do
    fill_graveyard!
    top = p1.library.first
    cast!

    expect(top.zone).to be_exile
    expect(game.play_permissions.permits?(top, p1)).to be(true)
  end
end
