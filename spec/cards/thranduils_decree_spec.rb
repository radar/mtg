# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThranduilsDecree do
  include_context "two player game"

  let(:decree) { Card("Thranduil's Decree", owner: p1) }

  before do
    go_to_main_phase_for!(p2)
    p1.hand.add(decree)
  end

  def cast_decree_on(spell)
    p1.add_mana(blue: 6)
    p1.cast(card: decree) { |a| a.pay_mana(generic: { blue: 4 }, blue: 2).targeting(spell) }
    game.stack.resolve!
  end

  it "exiles a countered permanent spell and lets you cast it free" do
    bears = Card("Grizzly Bears", owner: p2)
    p2.hand.add(bears)
    p2.add_mana(green: 2)
    p2.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    cast_decree_on(game.stack.spells.first)

    expect(bears.zone).to be_exile
    expect(p2.graveyard).not_to include(bears)

    # free cast needs sorcery timing: p1's own turn
    go_to_main_phase_for!(p1)
    p1.cast(card: bears) { |a| a.pay_mana({}) }
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "puts a countered nonpermanent spell into the graveyard" do
    shock = Card("Lightning Bolt", owner: p2)
    p2.hand.add(shock)
    p2.add_mana(red: 1)
    p2.cast(card: shock) { |a| a.pay_mana(red: 1).targeting(p1) }
    cast_decree_on(game.stack.spells.first)

    expect(shock.zone).to be_graveyard
    expect(p1.life).to eq(20)
  end
end
