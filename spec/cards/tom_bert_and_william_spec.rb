# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TomBertAndWilliam do
  include_context "two player game"

  let!(:trolls) { ResolvePermanent("Tom, Bert, And William", owner: p1) }

  def returned = p1.permanents.find { _1.name == "Tom, Bert, and William" }

  it "sacrifices another creature to draw cards equal to its power, then discard" do
    giant = ResolvePermanent("Axegrinder Giant", owner: p1)
    p1.add_mana(colorless: 1)
    library_before = p1.library.count
    p1.activate_ability(ability: trolls.activated_abilities.first) do
      _1.pay_mana(generic: { colorless: 1 })
      _1.pay_sacrifice(giant)
    end
    game.stack.resolve!

    expect(p1.library.count).to eq(library_before - 6)
    expect(giant.card.zone).to be_graveyard
    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end

  it "returns to the battlefield as a noncreature artifact when it dies" do
    trolls.destroy!
    game.settle!

    expect(returned).not_to be_nil
    expect(returned.creature?).to eq(false)
    expect(returned.artifact?).to eq(true)
  end

  it "does not return a second time once it's an artifact" do
    trolls.destroy!
    game.settle!
    returned.destroy!
    game.settle!

    expect(returned).to be_nil
  end
end
