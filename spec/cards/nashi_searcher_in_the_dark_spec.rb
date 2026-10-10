# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NashiSearcherInTheDark do
  include_context "two player game"

  let!(:nashi) { ResolvePermanent("Nashi, Searcher In The Dark", owner: p1) }
  let(:bears) { Card("Grizzly Bears") }
  let(:eidolon) { Card("Eidolon Of Blossoms") }

  # Past the draw step, so the cards stacked on the library aren't drawn.
  before { go_to_main_phase! }

  def hit_player
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(nashi, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!
  end

  it "is a 2/2 with menace" do
    expect([nashi.power, nashi.toughness]).to eq([2, 2])
    expect(nashi).to be_menace
  end

  it "mills that many cards and may take enchantment cards from among them" do
    p1.library.add(bears)
    p1.library.add(eidolon)
    graveyard_before = p1.graveyard.count
    hit_player
    expect(p1.graveyard.count).to eq(graveyard_before + 2)

    game.resolve_choice!(cards: [eidolon])

    expect(p1.hand.cards).to include(eidolon)
    expect(p1.hand.cards).not_to include(bears)
    expect(nashi.power).to eq(2)
  end

  it "may take legendary cards" do
    legend = Card("Nashi, Searcher In The Dark")
    p1.library.add(bears)
    p1.library.add(legend)
    hit_player
    game.resolve_choice!(cards: [legend])

    expect(p1.hand.cards).to include(legend)
  end

  it "gets a +1/+1 counter if no card is put into hand" do
    p1.library.add(bears)
    p1.library.add(Card("Grizzly Bears"))
    hit_player
    game.resolve_choice!(cards: [])
    game.settle!

    expect([nashi.power, nashi.toughness]).to eq([3, 3])
  end

  it "doesn't take non-legendary non-enchantment cards" do
    p1.library.add(bears)
    p1.library.add(Card("Grizzly Bears"))
    hit_player

    expect { game.resolve_choice!(cards: [bears]) }.to raise_error(ArgumentError)
  end
end
