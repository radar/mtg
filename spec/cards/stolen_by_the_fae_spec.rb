# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StolenByTheFae do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(target, x:)
    card = Card("Stolen By The Fae", owner: p1)
    p1.hand.add(card)
    p1.add_mana(blue: x + 2)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { blue: x }, blue: 2).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  def faeries = p1.creatures.select { _1.name == "Faerie" && _1.token? }

  it "returns a creature with mana value X to its owner's hand and makes X 1/1 flying Faeries" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2) # mana value 2
    cast(bears, x: 2)

    expect(p2.hand.map(&:name)).to include("Grizzly Bears")
    expect(faeries.count).to eq(2)
    expect([faeries.first.power, faeries.first.toughness]).to eq([1, 1])
    expect(faeries.first).to be_flying
    expect(faeries.first.colors).to eq([:blue])
  end

  it "can't target a creature whose mana value isn't X" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    spell = Card("Stolen By The Fae", owner: p1)
    action = Magic::Actions::Cast.new(game: game, player: p1, card: spell, value_for_x: 3)

    expect(action.can_target?(bears)).to be false
    expect(Magic::Actions::Cast.new(game: game, player: p1, card: spell, value_for_x: 2).can_target?(bears)).to be true
  end

  it "bounces a token (mana value 0) with X = 0 and makes no Faeries" do
    token = Magic::Cards::SiegeGangCommander::GoblinToken.new(game: game, owner: p2).resolve!
    cast(token, x: 0)

    expect(faeries).to be_empty
    expect(game.battlefield.permanents).not_to include(token)
  end
end
