# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Disenchant do
  include_context "two player game"

  let!(:anthem) { ResolvePermanent("Anthem Of Champions", owner: p2) }
  let!(:collar) { ResolvePermanent("Basilisk Collar", owner: p2) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def disenchant(target)
    p1.add_mana(white: 2)
    p1.cast(card: Card("Disenchant", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(target) }
    game.stack.resolve!
    game.tick!
  end

  it "destroys target enchantment" do
    disenchant(anthem)

    expect(anthem.card.zone).to be_graveyard
  end

  it "destroys target artifact" do
    disenchant(collar)

    expect(collar.card.zone).to be_graveyard
  end

  it "can't target a creature" do
    p1.add_mana(white: 2)

    expect { p1.cast(card: Card("Disenchant", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
