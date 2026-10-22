# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GlimpseTheImpossible do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast
    card = Card("Glimpse The Impossible", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  def end_step!
    current_turn.end!
    current_turn.cleanup!
    game.settle!
  end

  let!(:top) { [Card("Forest", owner: p1), Card("Grizzly Bears", owner: p1), Card("Island", owner: p1)] }

  before { top.reverse_each { p1.library.add(_1) } }

  it "exiles the top three cards of your library" do
    cast
    expect(top.map(&:zone)).to all(be_exile)
  end

  it "lets you play those cards this turn" do
    cast
    expect(game.play_permissions.permits?(top[1], p1)).to be(true)
    p1.play_land(land: top[0])
    expect(p1.lands.map(&:name)).to include("Forest")
  end

  it "stops permitting play after the turn ends" do
    cast
    game.next_turn
    expect(game.play_permissions.permits?(top[1], p1)).to be(false)
  end

  it "puts unplayed cards into the graveyard at end step and makes a Spawn for each" do
    cast
    p1.play_land(land: top[0])
    end_step!

    expect(top[1].zone).to be_graveyard
    expect(top[2].zone).to be_graveyard
    expect(spawns.size).to eq(2)
  end

  it "makes no tokens when no cards remain exiled" do
    cast
    top.each { _1.move_to_hand! }
    end_step!

    expect(top.map(&:zone)).to all(be_hand)

    expect(spawns).to be_empty
  end
end
