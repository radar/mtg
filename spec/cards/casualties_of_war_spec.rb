# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CasualtiesOfWar do
  include_context "two player game"

  it "offers all five modes" do
    expect(described_class::MODES).to eq([
      described_class::DestroyArtifact,
      described_class::DestroyCreature,
      described_class::DestroyEnchantment,
      described_class::DestroyLand,
      described_class::DestroyPlaneswalker,
    ])
  end

  it "destroys a target artifact, creature, enchantment, land, and planeswalker when all modes are chosen" do
    artifact = ResolvePermanent("Mind Stone", owner: p2)
    creature = ResolvePermanent("Grizzly Bears", owner: p2)
    enchantment = ResolvePermanent("Pride Of The Perfect", owner: p2)
    land = ResolvePermanent("Forest", owner: p2)
    planeswalker = ResolvePermanent("Basri Ket", owner: p2)

    spell = Card("Casualties Of War", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(black: 4, green: 2)

    p1.cast(card: spell) do |action|
      action.choose_mode(described_class::DestroyArtifact) { |mode| mode.targeting(artifact) }
      action.choose_mode(described_class::DestroyCreature) { |mode| mode.targeting(creature) }
      action.choose_mode(described_class::DestroyEnchantment) { |mode| mode.targeting(enchantment) }
      action.choose_mode(described_class::DestroyLand) { |mode| mode.targeting(land) }
      action.choose_mode(described_class::DestroyPlaneswalker) { |mode| mode.targeting(planeswalker) }
      action.pay_mana(generic: { black: 2 }, black: 2, green: 2)
    end
    game.stack.resolve!

    expect(artifact.card.zone).to be_graveyard
    expect(creature.card.zone).to be_graveyard
    expect(enchantment.card.zone).to be_graveyard
    expect(land.card.zone).to be_graveyard
    expect(planeswalker.card.zone).to be_graveyard
  end

  it "can destroy just a single chosen mode's target" do
    creature = ResolvePermanent("Grizzly Bears", owner: p2)

    spell = Card("Casualties Of War", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(black: 4, green: 2)

    p1.cast(card: spell) do |action|
      action.choose_mode(described_class::DestroyCreature) { |mode| mode.targeting(creature) }
      action.pay_mana(generic: { black: 2 }, black: 2, green: 2)
    end
    game.stack.resolve!

    expect(creature.card.zone).to be_graveyard
  end
end
