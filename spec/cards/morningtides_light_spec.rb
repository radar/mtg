# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MorningtidesLight do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Morningtide's Light", owner: p1) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Courser Of Kruphix", owner: p2) }

  def cast(*targets)
    p1.hand.add(card)
    p1.add_mana(white: 4)
    p1.cast(card:) { _1.pay_mana(generic: { white: 3 }, white: 1).targeting(*targets) }
    game.stack.resolve!
    game.settle!
  end

  def end_step!
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p1))
    game.settle!
  end

  it "exiles any number of target creatures" do
    cast(mine, theirs)

    expect([mine, theirs].map { _1.card.zone }).to all(be_exile)
  end

  it "may exile none" do
    cast

    expect(mine.zone).to be_battlefield
  end

  it "returns them tapped under their owners' control at the beginning of the next end step" do
    cast(mine, theirs)
    end_step!
    returned = (p1.creatures + p2.creatures)

    expect(returned.map(&:name)).to contain_exactly("Grizzly Bears", "Courser of Kruphix")
    expect(returned).to all(be_tapped)
    expect(p1.creatures.first.controller).to eq(p1)
    expect(p2.creatures.first.controller).to eq(p2)
  end

  it "returns them only once" do
    cast(mine)
    end_step!
    end_step!

    expect(p1.creatures.count).to eq(1)
  end

  it "doesn't return a card that has since left exile" do
    cast(mine)
    mine.card.move_to_hand!(p1)
    end_step!

    expect(p1.creatures).to be_empty
  end

  it "prevents all damage that would be dealt to you until your next turn" do
    cast(theirs)
    p2_bolt = Card("Lightning Bolt", owner: p2)
    go_to_main_phase_for!(p2)
    p2.hand.add(p2_bolt)
    p2.add_mana(red: 1)
    p2.cast(card: p2_bolt) { _1.pay_mana(red: 1).targeting(p1) }
    game.stack.resolve!

    expect(p1.life).to eq(20)
  end

  it "the prevention ends when your next turn begins" do
    cast
    game.next_turn
    game.next_turn
    go_to_main_phase!
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)
    p2.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p1) }
    game.stack.resolve!

    expect(p1.life).to be < 20
  end

  it "doesn't prevent damage to the opponent" do
    cast
    bolt = Card("Lightning Bolt", owner: p1)
    p1.hand.add(bolt)
    p1.add_mana(red: 1)
    p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(17)
  end

  it "exiles itself instead of going to the graveyard" do
    cast

    expect(card.zone).to be_exile
  end
end
