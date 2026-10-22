# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DepthDefiler do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:defiler) { Card("Depth Defiler", owner: p1) }
  let!(:opp_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:own_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:fodder){ Card("Forest", owner: p1) }

  def cast_defiler(kicked:)
    p1.hand.add(defiler)
    p1.hand.add(fodder)
    p1.add_mana(blue: 2, colorless: 4)
    action = cast_action(card: defiler, player: p1)
    action.pay_mana(blue: 2, generic: { colorless: 3 })
    action.pay_kicker(colorless: 1) if kicked
    game.take_action(action)
    game.settle!
  end

  it "is a devoid 3/5 Eldrazi" do
    permanent = ResolvePermanent("Depth Defiler", owner: p1)

    expect(defiler.colors).to be_empty
    expect([permanent.power, permanent.toughness]).to eq([3, 5])
  end

  it "offers only one mode when not kicked, and bounce returns a creature" do
    cast_defiler(kicked: false)
    choice = game.choices.last

    expect(choice).to be_a(described_class::ModeChoice)
    game.resolve_choice!(mode: :bounce)
    game.resolve_choice!(target: opp_bears)

    expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
    expect(game.choices).to be_empty
  end

  it "loots the chosen player when that mode is chosen and not kicked" do
    cast_defiler(kicked: false)
    game.resolve_choice!(mode: :loot)
    hand_before = p1.hand.count
    game.resolve_choice!(target: p1)

    expect(p1.hand.count).to eq(hand_before + 2)
    game.resolve_choice!(card: p1.hand.cards.first)

    expect(p1.hand.count).to eq(hand_before + 1)
    expect(opp_bears.zone).to eq(game.battlefield)
  end

  it "skipping the mode choice takes the first mode" do
    cast_defiler(kicked: false)
    game.skip_choice!

    expect(game.choices.last).to be_a(described_class::BounceChoice)
  end

  it "does both modes when kicked" do
    cast_defiler(kicked: true)
    expect(game.choices.map(&:class)).to include(described_class::BounceChoice, described_class::LootChoice)
    expect(game.choices.map(&:class)).not_to include(described_class::ModeChoice)

    hand_before = p1.hand.count
    game.resolve_choice!(target: p1)
    game.resolve_choice!(card: p1.hand.cards.first)
    game.resolve_choice!(target: opp_bears)

    expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
    expect(p1.hand.count).to eq(hand_before + 1)
  end
end
