require "spec_helper"

RSpec.describe Magic::Cards::Abundance do
  include_context "two player game"

  let!(:abundance) { ResolvePermanent("Abundance", owner: p1) }

  # Seven cards of opening hand, then (top to bottom) Island, Island, Grizzly Bears, Forest, and the rest.
  def p1_library
    [*Array.new(7) { Card("Mountain") }, Card("Island"), Card("Island"), Card("Grizzly Bears"), Card("Forest"), *Array.new(10) { Card("Island") }]
  end

  def draw_a_card
    game.add_effect(Magic::Effects::DrawCards.new(source: p1, player: p1))
  end

  it "asks what to draw instead when you would draw a card" do
    draw_a_card

    choice = game.choices.last
    expect(choice).to be_a(described_class::Choice)
    expect(choice.modes.keys).to eq(%i[land nonland draw])
  end

  it "lets you draw normally" do
    top = p1.library.first
    draw_a_card
    game.resolve_choice!(mode: :draw)

    expect(p1.hand).to include(top)
  end

  it "reveals until a nonland card, taking it and putting the rest on the bottom in order" do
    first, second, bears = p1.library.first(3)
    draw_a_card
    game.resolve_choice!(mode: :nonland)

    expect(p1.hand).to include(bears)
    expect(p1.library.last(2)).to eq([first, second])
  end

  it "reveals until a land" do
    top = p1.library.first
    draw_a_card
    game.resolve_choice!(mode: :land)

    expect(p1.hand).to include(top)
    expect(top).to be_land
  end

  it "applies to the monarch's draw at the beginning of their end step" do
    game.make_monarch!(p1)
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: p1))

    expect(game.choices.last).to be_a(described_class::Choice)
  end

  it "does not apply to an opponent's draws" do
    game.add_effect(Magic::Effects::DrawCards.new(source: p2, player: p2))

    expect(game.choices).to be_empty
  end
end
