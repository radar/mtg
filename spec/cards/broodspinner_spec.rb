# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Broodspinner do
  include_context "two player game"

  subject(:broodspinner) { ResolvePermanent("Broodspinner", owner: p1) }

  def insects = p1.creatures.select { _1.type?("Insect") }

  it "is a 2/3 Spider with reach" do
    expect([broodspinner.power, broodspinner.toughness]).to eq([2, 3])
    expect(broodspinner.type?("Spider")).to be true
    expect(broodspinner.has_keyword?(Magic::Cards::Keywords::REACH)).to be true
  end

  it "surveils 2 when it enters" do
    broodspinner
    game.settle!
    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
  end

  it "sacrifices itself to create an Insect per card type in the graveyard" do
    broodspinner
    game.settle!
    game.skip_choice! while game.choices.any?
    %w[Island Lightning\ Bolt Grizzly\ Bears].each { p1.graveyard.add(Card(_1, owner: p1)) }
    p1.add_mana(black: 1, green: 1, colorless: 0, red: 4)
    ability = broodspinner.activated_abilities.first
    p1.activate_ability(ability: ability) do
      _1.pay_mana(generic: { red: 4 }, black: 1, green: 1)
    end
    game.stack.resolve!
    game.tick!

    expect(broodspinner.zone).to be_nil
    # Land, instant, creature (the sacrificed Broodspinner itself) = 3 types
    expect(insects.count).to eq(3)
    expect(insects).to all(satisfy { _1.has_keyword?(Magic::Cards::Keywords::FLYING) })
  end
end
