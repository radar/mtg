# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MockingSprite do
  include_context "two player game"

  let!(:sprite) { ResolvePermanent("Mocking Sprite", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { game.tick! }

  it "is a 2/1 flyer" do
    expect([sprite.power, sprite.toughness]).to eq([2, 1])
    expect(sprite).to be_flying
  end

  it "makes instant and sorcery spells you cast cost {1} less" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Sure Strike", owner: p1)) { |a| a.pay_mana(red: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect(bears.power).to eq(5)
  end

  it "doesn't make an opponent's spells cheaper" do
    p2.add_mana(red: 1)

    expect { p2.cast(card: Card("Sure Strike", owner: p2)) { |a| a.pay_mana(red: 1).targeting(rival) } }
      .to raise_error(Magic::Costs::Mana::CannotPay)
  end

  it "doesn't reduce creature spells" do
    go_to_main_phase!
    p1.add_mana(green: 1)

    expect { p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(green: 1) } }
      .to raise_error(Magic::Costs::Mana::CannotPay)
  end
end
