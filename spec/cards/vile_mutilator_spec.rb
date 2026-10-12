# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VileMutilator do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opp_bears) { ResolvePermanent("Ordinary Bear", owner: p2) }
  let!(:opp_enchantment) { ResolvePermanent("Abundance", owner: p2) }
  let(:mutilator_card) { Card("Vile Mutilator", owner: p1).tap { p1.hand.add(_1) } }

  def cast_mutilator(sacrifice)
    p1.add_mana(black: 7)
    p1.cast(card: mutilator_card) do |action|
      action.pay_mana(generic: { black: 5 }, black: 2)
      action.pay_sacrifice(sacrifice)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 6/5 Demon with flying and trample" do
    mutilator = ResolvePermanent("Vile Mutilator", owner: p1)

    expect([mutilator.power, mutilator.toughness]).to eq([6, 5])
    expect(mutilator).to be_flying
    expect(mutilator).to be_trample
  end

  it "requires sacrificing a creature or enchantment as an additional cost" do
    cast_mutilator(fodder)

    expect(p1.permanents.map(&:name)).to include("Vile Mutilator")
    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "makes each opponent sacrifice a nontoken enchantment, then a nontoken creature" do
    cast_mutilator(fodder)

    expect(p2.graveyard.cards.map(&:name)).to contain_exactly("Abundance", "Ordinary Bear")
  end

  context "when the opponent has several of each" do
    let!(:other_enchantment) { ResolvePermanent("Land Tax", owner: p2) }
    let!(:other_bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "lets them choose which to sacrifice, enchantment first" do
      cast_mutilator(fodder)
      expect(game.choices.first.choices).to contain_exactly(opp_enchantment, other_enchantment)
      game.resolve_choice!(target: other_enchantment)
      game.settle!
      expect(game.choices.first.choices).to contain_exactly(opp_bears, other_bear)
      game.resolve_choice!(target: opp_bears)
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to contain_exactly("Land Tax", "Ordinary Bear")
    end
  end
end
