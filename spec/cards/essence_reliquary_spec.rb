# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EssenceReliquary do
  include_context "two player game"

  let!(:reliquary) { ResolvePermanent("Essence Reliquary", owner: p1) }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:ability) { reliquary.activated_abilities.first }

  before { go_to_main_phase! }

  def activate(target)
    p1.activate_ability(ability: ability) { _1.targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  def enchant(creature, player, aura_name = "Ethereal Armor")
    aura = Card(aura_name, owner: player)
    player.hand.add(aura)
    player.add_mana(white: 1)
    player.cast(card: aura) do |action|
      action.targeting(creature)
      action.pay_mana(white: 1)
    end
    game.stack.resolve!
    game.settle!
    aura
  end

  it "returns another permanent you control to its owner's hand" do
    activate(bear)

    expect(bear.card.zone).to eq(p1.hand)
    expect(p1.creatures).to be_empty
    expect(reliquary).to be_tapped
  end

  it "returns Auras you control attached to it as well" do
    aura = enchant(bear, p1)
    expect(aura.zone).to eq(game.battlefield)

    activate(bear)

    expect(aura.zone).to eq(p1.hand)
    expect(bear.card.zone).to eq(p1.hand)
  end

  it "does not return Auras an opponent controls attached to it" do
    go_to_main_phase_for!(p2)
    aura = enchant(bear, p2)
    go_to_main_phase_for!(p1)

    activate(bear)

    expect(p1.hand.cards).not_to include(aura)
    expect(p2.hand.cards).not_to include(aura)
    expect(bear.card.zone).to eq(p1.hand)
  end

  it "can't target itself" do
    expect(ability.target_choices).not_to include(reliquary)
    expect(ability.target_choices).to include(bear)
  end

  it "can't target a permanent an opponent controls" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)

    expect(ability.target_choices).not_to include(theirs)
  end

  it "can only be activated during your turn" do
    go_to_main_phase_for!(p2)

    expect { p1.activate_ability(ability: ability) { _1.targeting(bear) } }.to raise_error(Magic::IllegalAction)
    expect(p1.creatures).to include(bear)
  end

  it "requires the Reliquary to be untapped" do
    reliquary.tap!

    expect { p1.activate_ability(ability: ability) { _1.targeting(bear) } }.to raise_error(Magic::IllegalAction)
  end
end
