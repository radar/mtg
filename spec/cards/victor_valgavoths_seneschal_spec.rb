# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VictorValgavothsSeneschal do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:victor) { ResolvePermanent("Victor Valgavoths Seneschal", owner: p1) }

  def eerie!(name = "Elderfang Venom")
    ResolvePermanent(name, owner: p1)
    game.settle!
  end

  it "is a 3/3 legendary Human Warlock" do
    expect([victor.power, victor.toughness]).to eq([3, 3])
    expect(victor.card).to be_legendary
  end

  it "surveils 2 the first time it resolves each turn" do
    eerie_enchantment_enters!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(2)
  end

  it "makes each opponent discard a card the second time" do
    eerie_enchantment_enters!
    game.skip_choice!
    hand_size = p2.hand.cards.count

    eerie!("Sanctum Of Tranquil Light")

    discard = game.choices.last
    expect(discard).to be_a(Magic::Choice::Discard)
    expect(discard.player).to eq(p2)
    game.resolve_choice!(card: p2.hand.cards.first)
    expect(p2.hand.cards.count).to eq(hand_size - 1)
  end

  context "the third time" do
    let!(:dead_bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
    let!(:their_dead) { Card("Grizzly Bears", owner: p2).tap { p2.graveyard.add(_1) } }

    before do
      eerie_enchantment_enters!
      game.skip_choice!
      eerie!("Sanctum Of Tranquil Light")
      game.resolve_choice!(card: p2.hand.cards.first)
    end

    it "puts a creature card from a graveyard onto the battlefield under your control" do
      eerie!("Elderfang Venom")

      choice = game.choices.last
      expect(choice.choices).to contain_exactly(dead_bears, their_dead)
      game.resolve_choice!(target: their_dead)

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
      expect(p2.graveyard.cards).not_to include(their_dead)
    end

    it "does nothing the fourth time" do
      eerie!("Elderfang Venom")
      game.skip_choice! while game.choices.any?
      eerie!("Elderfang Venom")

      expect(game.choices).to be_empty
    end
  end

  it "starts counting again the next turn" do
    eerie_enchantment_enters!
    game.skip_choice!
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    game.next_turn
    game.next_turn
    go_to_main_phase!
    game.settle!
    game.skip_choice! while game.choices.any? # Sanctum of Calm Waters' first main phase trigger

    eerie!("Elderfang Venom")
    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  it "triggers whenever you fully unlock a Room" do
    room = eerie_room
    game.skip_choice!

    eerie_fully_unlock_room!(room)
    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end
end
