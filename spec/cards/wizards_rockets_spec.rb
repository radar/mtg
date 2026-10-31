# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WizardsRockets do
  include_context "two player game"

  let!(:rockets) { ResolvePermanent("Wizard's Rockets", owner: p1) }

  def activate(x:, colors:, paid: { red: x })
    rockets.untap!
    p1.add_mana(**paid) if paid.any?
    p1.activate_ability(ability: rockets.activated_abilities.first, value_for_x: x) do |a|
      a.pay_mana(x: paid) if x.positive?
      a.choose(colors)
    end
    game.settle!
  end

  it "enters tapped" do
    expect(rockets).to be_tapped
  end

  it "adds X mana of a single chosen color and sacrifices itself" do
    p1.mana_pool.clear
    activate(x: 3, colors: :green, paid: { red: 3 })

    expect(p1.mana_pool[:green]).to eq(3)
    expect(p1.permanents).not_to include(rockets)
    expect(p1.graveyard.cards.map(&:name)).to include("Wizard's Rockets")
  end

  it "adds X mana in any combination of colors" do
    p1.mana_pool.clear
    activate(x: 3, colors: %i[white white blue], paid: { red: 3 })

    expect(p1.mana_pool[:white]).to eq(2)
    expect(p1.mana_pool[:blue]).to eq(1)
  end

  it "rejects a combination that doesn't total X" do
    p1.mana_pool.clear

    expect { activate(x: 3, colors: %i[white blue], paid: { red: 3 }) }.to raise_error(ArgumentError, /choose 3 mana/)
  end

  it "requires the artifact to be untapped" do
    p1.add_mana(red: 1)
    rockets.tap!

    expect do
      p1.activate_ability(ability: rockets.activated_abilities.first, value_for_x: 1) do |a|
        a.pay_mana(x: { red: 1 })
        a.choose(:red)
      end
    end.to raise_error(StandardError)
    expect(p1.permanents).to include(rockets)
  end

  it "draws a card when it is put into a graveyard from the battlefield" do
    hand = p1.hand.count
    rockets.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand + 1)
  end

  it "draws a card when sacrificed for its ability" do
    hand = p1.hand.count
    activate(x: 1, colors: :red, paid: { red: 1 })

    expect(p1.hand.count).to eq(hand + 1)
  end

  it "doesn't draw when exiled instead of going to a graveyard" do
    hand = p1.hand.count
    rockets.exile!
    game.settle!

    expect(p1.hand.count).to eq(hand)
  end
end
