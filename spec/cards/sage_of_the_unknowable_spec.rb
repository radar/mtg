# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SageOfTheUnknowable do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:sage) { ResolvePermanent("Sage Of The Unknowable", owner: p1) }

  def tap_sage
    p1.activate_ability(ability: sage.activated_abilities.first)
  end

  it "is a 0/4" do
    expect([sage.power, sage.toughness]).to eq([0, 4])
  end

  it "taps for restricted colorless mana" do
    tap_sage
    expect(sage).to be_tapped
    expect(p1.restricted_mana.map(&:color)).to eq([:colorless])
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "pays for a colorless spell" do
    tap_sage
    ring = Card("Sol Ring", owner: p1)
    p1.hand.add(ring)
    p1.cast(card: ring) { |a| a.pay_mana(generic: { colorless: 1 }) }
    expect(p1.restricted_mana).to be_empty
    game.stack.resolve!
    expect(game.battlefield.map(&:name)).to include("Sol Ring")
  end

  it "cannot pay for a colored spell" do
    tap_sage
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    action = Magic::Actions::Cast.new(card: bears, player: p1, game: game)
    expect(action.mana_cost.can_pay?(p1)).to eq(false)
  end

  it "pays to activate an ability" do
    curator = ResolvePermanent("Keen Eyed Curator", owner: p1)
    target = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(target)
    tap_sage
    p1.activate_ability(ability: curator.activated_abilities.first) do
      _1.targeting(target)
      _1.pay_mana(generic: { colorless: 1 })
    end
    expect(p1.restricted_mana).to be_empty
  end
end
