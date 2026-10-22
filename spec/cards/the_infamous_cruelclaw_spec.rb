# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheInfamousCruelclaw do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:cruelclaw) { ResolvePermanent("The Infamous Cruelclaw", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:discard_fodder) do
    card = Card("Forest", owner: p1)
    p1.hand.add(card)
    card
  end

  def put_on_top(name)
    card = Card(name, owner: p1)
    p1.library.add(card)
    card
  end

  def deal_combat_damage(to: p2)
    game.notify!(Magic::Events::CombatDamageDealt.new(source: cruelclaw, target: to, damage: 3))
    game.settle!
  end

  it "is a 3/3 with menace" do
    expect([cruelclaw.power, cruelclaw.toughness]).to eq([3, 3])
    expect(cruelclaw).to have_keyword(:menace)
  end

  it "exiles cards until a nonland card, and does nothing for damage to a creature" do
    bolt = put_on_top("Lightning Bolt")
    land = put_on_top("Mountain")
    deal_combat_damage(to: bears)

    expect(bolt.zone).to eq(p1.library)
    expect(land.zone).to eq(p1.library)
    expect(game.choices).to be_empty
  end

  it "exiles lands until it finds a nonland card, then offers to cast it" do
    bolt = put_on_top("Lightning Bolt")
    land = put_on_top("Mountain")
    deal_combat_damage

    expect(land.zone).to be_exile
    expect(bolt.zone).to be_exile
    expect(game.choices.last).to be_a(described_class::DamageTrigger::MayCast)
  end

  it "lets you choose the target of the spell cast by discarding a card" do
    put_on_top("Lightning Bolt")
    deal_combat_damage
    game.resolve_choice!
    game.resolve_choice!(card: discard_fodder)
    choice = game.choices.last

    expect(choice).to be_a(described_class::DamageTrigger::TargetChoice)
    expect(choice.choices).to include(bears, p1, p2)
    game.resolve_choice!(target: p2)
    game.stack.resolve!
    game.settle!

    expect(discard_fodder.zone).to eq(p1.graveyard)
    expect(p2.life).to eq(17)
    expect(bears.zone).to eq(game.battlefield)
  end

  it "targets the first legal target if the target choice is skipped" do
    put_on_top("Lightning Bolt")
    deal_combat_damage
    game.resolve_choice!
    game.resolve_choice!(card: discard_fodder)
    game.skip_choice!

    expect(game.stack.spells.map { _1.card.name }).to include("Lightning Bolt")
    expect(game.choices).to be_empty
  end

  it "does not cast the card if you decline" do
    bolt = put_on_top("Lightning Bolt")
    deal_combat_damage
    game.skip_choice!

    expect(bolt.zone).to be_exile
    expect(game.stack.spells).to be_empty
  end
end
