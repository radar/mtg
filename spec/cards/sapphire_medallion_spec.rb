# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SapphireMedallion do
  include_context "two player game"

  let!(:medallion) { ResolvePermanent("Sapphire Medallion", owner: p1) }

  before do
    go_to_main_phase!
    game.tick!
  end

  it "makes blue spells you cast cost {1} less" do
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Creeping Peeper", owner: p1)) { |a| a.pay_mana(blue: 1) }
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Creeping Peeper")
  end

  it "doesn't reduce non-blue spells" do
    p1.add_mana(green: 1)

    expect { p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(green: 1) } }
      .to raise_error(Magic::Costs::Mana::CannotPay)
  end
end
