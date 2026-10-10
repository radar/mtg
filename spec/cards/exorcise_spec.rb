# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Exorcise do
  include_context "two player game"
  before { go_to_main_phase! }

  def exorcise(target)
    p1.add_mana(white: 2)
    cast_and_resolve(card: Card("Exorcise", owner: p1), player: p1) do |action|
      action.targeting(target)
      action.pay_mana(generic: { white: 1 }, white: 1)
    end
    game.settle!
  end

  it "exiles a creature with power 4 or greater" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    target = ResolvePermanent("Cautious Survivor", owner: p2)
    exorcise(target)

    expect(game.exile.cards.map(&:name)).to include("Cautious Survivor")
    expect(p2.creatures.map(&:name)).not_to include("Cautious Survivor")
  end

  it "exiles an artifact" do
    target = ResolvePermanent("Sol Ring", owner: p2)
    exorcise(target)

    expect(game.exile.cards.map(&:name)).to include("Sol Ring")
  end

  it "cannot target a creature with power less than 4" do
    small = ResolvePermanent("Grizzly Bears", owner: p2)
    big = ResolvePermanent("Cautious Survivor", owner: p2)
    card = Card("Exorcise", owner: p1)

    expect(card.target_choices).to include(big)
    expect(card.target_choices).not_to include(small)
  end
end
