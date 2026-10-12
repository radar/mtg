require 'spec_helper'

RSpec.describe Magic::Cards::PestInfestation do
  include_context "two player game"

  let(:card) { Card("Pest Infestation", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(card)
  end

  def cast(x:)
    p1.add_mana(green: x + 1)
    p1.cast(card: card, value_for_x: x) { |a| a.pay_mana(green: 1, x: { green: x }) }
    game.stack.resolve!
    game.settle!
  end

  def pests = p1.creatures.select { |c| c.name == "Pest" }

  it "creates twice X Pests" do
    cast(x: 2)
    expect(pests.count).to eq(4)
  end

  it "creates nothing for X = 0" do
    cast(x: 0)
    expect(pests).to be_empty
  end

  it "gains 1 life when a Pest dies" do
    cast(x: 1)
    expect { pests.first.destroy!; game.settle! }.to change { p1.life }.by(1)
  end
end
