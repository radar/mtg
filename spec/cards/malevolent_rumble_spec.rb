# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MalevolentRumble do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast
    card = Card("Malevolent Rumble", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  let!(:top) do
    [Card("Forest", owner: p1), Card("Grizzly Bears", owner: p1), Card("Lightning Bolt", owner: p1), Card("Island", owner: p1)]
  end

  before { top.reverse_each { p1.library.add(_1) } }

  it "lets you put a permanent card from the top four into your hand and the rest into your graveyard" do
    cast
    expect(game.choices.first.choices).to contain_exactly(top[0], top[1], top[3])
    game.resolve_choice!(target: top[1])

    expect(top[1].zone).to be_hand
    expect(top.values_at(0, 2, 3).map(&:zone)).to all(be_graveyard)
  end

  it "does not offer nonpermanent cards" do
    cast
    expect(game.choices.first.choices).not_to include(top[2])
    expect { game.resolve_choice!(target: top[2]) }.to raise_error(ArgumentError)
  end

  it "puts all four into the graveyard if you decline" do
    cast
    game.skip_choice!

    expect(top.map(&:zone)).to all(be_graveyard)
  end

  it "reveals the top four cards" do
    cast
    event = game.current_turn.events.find { _1.is_a?(Magic::Events::CardsRevealed) }
    expect(event.cards).to eq(top)
  end

  it "creates an Eldrazi Spawn token" do
    cast
    expect(spawns.size).to eq(1)
    expect(spawns.first.power).to eq(0)
    expect(spawns.first.toughness).to eq(1)
  end
end
