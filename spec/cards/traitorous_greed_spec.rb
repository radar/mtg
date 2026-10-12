# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TraitorousGreed do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast(target)
    card = Card("Traitorous Greed", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 4)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 3 }, red: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "gains control of the creature, untaps it and gives it haste" do
    bears.tap!
    cast(bears)
    game.resolve_choice!(mode: :green)
    game.tick!

    expect(bears.controller).to eq(p1)
    expect(bears).to be_untapped
    expect(bears.has_keyword?(Magic::Cards::Keywords::HASTE)).to eq(true)
  end

  it "adds two mana of the chosen color" do
    cast(bears)
    game.resolve_choice!(mode: :green)

    expect(p1.mana_pool[:green]).to eq(2)
  end

  it "returns the creature at end of turn" do
    cast(bears)
    game.resolve_choice!(mode: :green)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears.controller).to eq(p2)
  end
end
