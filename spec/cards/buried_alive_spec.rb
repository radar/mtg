# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BuriedAlive do
  include_context "two player game"

  let(:card) { Card("Buried Alive", owner: p1) }
  let(:bears) { Array.new(4) { Card("Grizzly Bears", owner: p1) } }
  let(:island) { Card("Island", owner: p1) }

  before do
    go_to_main_phase!
    p1.library.items.clear
    (bears + [island]).each { p1.library.add(_1) }
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "offers only creature cards" do
    expect(game.choices.last.choices).to match_array(bears)
    expect(game.choices.last.choices).not_to include(island)
  end

  it "puts up to three chosen creature cards into the graveyard, then shuffles" do
    expect(p1).to receive(:shuffle!)
    game.resolve_choice!(targets: bears.first(3))
    expect(bears.first(3).map(&:zone)).to all(eq(p1.graveyard))
    expect(bears.last.zone).to eq(p1.library)
  end

  it "rejects choosing four creatures" do
    expect { game.resolve_choice!(targets: bears) }.to raise_error(ArgumentError)
  end

  it "can choose fewer than three" do
    game.resolve_choice!(targets: [bears.first])
    expect(bears.first.zone).to eq(p1.graveyard)
    expect(p1.graveyard.cards).to include(bears.first)
  end
end
