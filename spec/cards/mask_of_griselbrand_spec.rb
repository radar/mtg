# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MaskOfGriselbrand do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:mask) { ResolvePermanent("Mask Of Griselbrand", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def equip!
    p1.add_mana(green: 3)
    p1.activate_ability(ability: mask.activated_abilities.first) do |action|
      action.pay_mana(generic: { green: 3 })
      action.targeting(bears)
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a legendary Equipment" do
    expect(mask.card).to be_legendary
  end

  it "gives the equipped creature flying and lifelink" do
    equip!

    expect(bears).to have_keyword(:flying)
    expect(bears).to have_keyword(:lifelink)
  end

  it "lets you pay life equal to the creature's power to draw that many cards when it dies" do
    equip!
    hand = p1.hand.cards.count
    bears.destroy!
    game.settle!
    game.resolve_choice!

    expect(p1.life).to eq(18)
    expect(p1.hand.cards.count).to eq(hand + 2)
  end

  it "lets you decline" do
    equip!
    hand = p1.hand.cards.count
    bears.destroy!
    game.settle!
    game.skip_choice!

    expect(p1.life).to eq(20)
    expect(p1.hand.cards.count).to eq(hand)
  end

  it "doesn't trigger for an unequipped creature dying" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    equip!
    other.destroy!
    game.settle!

    expect(game.choices).to be_empty
  end
end
