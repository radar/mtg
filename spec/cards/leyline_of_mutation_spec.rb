# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LeylineOfMutation do
  include_context "two player game"

  def p1_library = [Card("Leyline Of Mutation", owner: p1), *13.times.map { Card("Forest", owner: p1) }]

  before do
    game.resolve_choice!
    go_to_main_phase!
  end

  let(:colossus) { Card("Baneslayer Angel", owner: p1).tap { p1.hand.add(_1) } } # {3}{W}{W}

  it "lets you pay {W}{U}{B}{R}{G} rather than a spell's mana cost" do
    p1.add_mana(white: 1, blue: 1, black: 1, red: 1, green: 1)
    p1.cast(card: colossus, pay_static_alternative: true) { _1.pay_mana(white: 1, blue: 1, black: 1, red: 1, green: 1) }
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to eq(["Baneslayer Angel"])
  end

  it "doesn't apply unless you ask for it" do
    p1.add_mana(white: 1, blue: 1, black: 1, red: 1, green: 1)

    expect { p1.cast(card: colossus) { _1.pay_mana(white: 1, blue: 1, black: 1, red: 1, green: 1) } }.to raise_error(StandardError)
  end

  it "applies to instants too" do
    bolt = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(white: 1, blue: 1, black: 1, red: 1, green: 1)
    p1.cast(card: bolt, pay_static_alternative: true) { _1.pay_mana(white: 1, blue: 1, black: 1, red: 1, green: 1).targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(17)
  end

  it "doesn't apply to your opponent" do
    game.next_turn
    go_to_main_phase!
    bolt = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
    p2.add_mana(white: 1, blue: 1, black: 1, red: 1, green: 1)

    expect { p2.cast(card: bolt, pay_static_alternative: true) { _1.pay_mana(white: 1, blue: 1, black: 1, red: 1, green: 1).targeting(p1) } }
      .to raise_error(StandardError)
  end
end
