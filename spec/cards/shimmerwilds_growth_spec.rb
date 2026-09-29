# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShimmerwildsGrowth do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:forest) { ResolvePermanent("Forest", owner: p1) }
  let(:card) { Card("Shimmerwilds Growth", owner: p1) }

  def enchant(land, color: :blue)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1).targeting(land) }
    game.stack.resolve!
    game.resolve_choice!(color:)
    game.tick!
  end

  it "makes the enchanted land the chosen color" do
    enchant(forest)

    expect(forest.colors).to eq([:blue])
  end

  it "adds an additional mana of the chosen color when the land is tapped for mana" do
    enchant(forest)
    forest.untap!
    p1.activate_ability(ability: forest.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:green]).to eq(1)
    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "doesn't affect other lands" do
    other = ResolvePermanent("Forest", owner: p1)
    enchant(forest)
    other.untap!
    p1.activate_ability(ability: other.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:blue]).to eq(0)
    expect(other.colors).to be_empty
  end

  it "can only enchant a land" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)

    expect { p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1).targeting(bears) } }.to raise_error(StandardError)
  end

  it "stops when the Aura leaves" do
    enchant(forest)
    aura = p1.permanents.find { _1.name == "Shimmerwilds Growth" }
    aura.destroy!
    game.settle!
    forest.untap!
    p1.activate_ability(ability: forest.activated_abilities.first) { _1.choose(:green) }

    expect(p1.mana_pool[:blue]).to eq(0)
    expect(forest.colors).to be_empty
  end
end
