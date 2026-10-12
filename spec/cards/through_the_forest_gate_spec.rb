# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThroughTheForestGate do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Through The Forest Gate", owner: p1) }

  def cast_it
    p1.hand.add(card)
    p1.add_mana(green: 8)
    p1.cast(card:) { |a| a.pay_mana(generic: { green: 6 }, green: 2) }
    game.stack.resolve!
  end

  it "puts chosen lands from the top twenty onto the battlefield tapped and gains 8 life" do
    forests = Array.new(3) { Card("Forest", owner: p1) }
    forests.each { p1.library.add(_1) }
    cast_it

    expect(p1.life).to eq(28)
    choice = game.choices.last
    expect(choice.choices.choices).to include(*forests)
    game.resolve_choice!(choices: forests.first(2))

    on_field = p1.lands.select { forests.include?(_1.card) }
    expect(on_field.size).to eq(2)
    expect(on_field).to all(be_tapped)
  end

  it "may choose no lands" do
    cast_it
    game.resolve_choice!(choices: [])

    expect(p1.lands).to be_empty
    expect(p1.life).to eq(28)
  end
end
