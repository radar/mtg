# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LionUmbra do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    bears.add_counter("+1/+1")
    game.settle!
  end

  def cast_umbra(target)
    p1.add_mana(green: 2)
    p1.cast(card: Card("Lion Umbra", owner: p1)) { |a| a.pay_mana(green: 2).targeting(target) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  def umbra = game.battlefield.permanents.find { _1.name == "Lion Umbra" }

  it "gives the enchanted modified creature +3/+3, reach and vigilance" do
    cast_umbra(bears)

    expect(bears.power).to eq(6)
    expect(bears.toughness).to eq(6)
    expect(bears.has_keyword?(Magic::Cards::Keywords::REACH)).to eq(true)
    expect(bears.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(true)
  end

  it "can't target a creature that isn't modified" do
    plain = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 2)
    action = p1.cast(card: Card("Lion Umbra", owner: p1)) { |a| a.pay_mana(green: 2) }

    expect(action.target_choices).to include(bears)
    expect(action.target_choices).not_to include(plain)
  end

  it "has umbra armor: destruction removes damage and destroys the Aura instead" do
    cast_umbra(bears)
    bears.destroy!
    game.settle!

    expect(bears.zone).to eq(game.battlefield)
    expect(p1.graveyard.cards.map(&:name)).to include("Lion Umbra")
    expect(umbra).to be_nil
  end
end
