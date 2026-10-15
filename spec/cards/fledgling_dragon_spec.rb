# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FledglingDragon do
  include_context "two player game"

  let!(:dragon) { ResolvePermanent("Fledgling Dragon", owner: p1) }

  def fill_graveyard!(player, count)
    count.times { player.graveyard.add(Card("Grizzly Bears", owner: player)) }
    game.tick!
  end

  def firebreathe!
    p1.add_mana(red: 1)
    p1.activate_ability(ability: dragon.activated_abilities.first) { _1.pay_mana(red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/2 flyer" do
    expect([dragon.power, dragon.toughness]).to eq([2, 2])
    expect(dragon).to have_keyword(Magic::Cards::Keywords::FLYING)
  end

  it "gets +3/+3 with seven cards in your graveyard" do
    fill_graveyard!(p1, 7)

    expect([dragon.power, dragon.toughness]).to eq([5, 5])
  end

  it "has no bonus with six cards in your graveyard" do
    fill_graveyard!(p1, 6)

    expect([dragon.power, dragon.toughness]).to eq([2, 2])
  end

  it "ignores the opponent's graveyard" do
    fill_graveyard!(p2, 7)

    expect([dragon.power, dragon.toughness]).to eq([2, 2])
  end

  it "loses the bonus when the graveyard drops below seven" do
    fill_graveyard!(p1, 7)
    p1.graveyard.cards.first.exile!
    game.tick!

    expect([dragon.power, dragon.toughness]).to eq([2, 2])
  end

  it "has {R}: +1/+0 with threshold" do
    fill_graveyard!(p1, 7)
    firebreathe!

    expect(dragon.power).to eq(6)
    expect(dragon.toughness).to eq(5)
  end

  it "can't pump without threshold" do
    fill_graveyard!(p1, 6)
    p1.add_mana(red: 1)

    expect { p1.activate_ability(ability: dragon.activated_abilities.first) { _1.pay_mana(red: 1) } }
      .to raise_error(Magic::IllegalAction)
    expect(dragon.power).to eq(2)
  end

  it "can't pump without red mana" do
    fill_graveyard!(p1, 7)
    p1.add_mana(blue: 1)

    expect { p1.activate_ability(ability: dragon.activated_abilities.first) { _1.pay_mana(blue: 1) } }
      .to raise_error(Magic::Costs::Mana::CannotPay)
  end
end
