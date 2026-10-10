# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VanishFromSight do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def vanish(target)
    p1.add_mana(blue: 4)
    p1.cast(card: Card("Vanish From Sight")) do
      _1.pay_mana(generic: { blue: 3 }, blue: 1).targeting(target)
    end
    game.stack.resolve!
  end

  it "lets the owner put the permanent on top of their library, then surveils 1" do
    vanish(bears)
    game.resolve_choice!(position: :top)

    expect(game.battlefield.permanents).not_to include(bears)
    expect(p2.library.first).to eq(bears.card)
    surveil = game.choices.find { _1.is_a?(Magic::Choice::Surveil) }
    expect(surveil.amount).to eq(1)
    expect(surveil.chooser).to eq(p1)
  end

  it "lets the owner put it on the bottom" do
    vanish(bears)
    game.resolve_choice!(position: :bottom)

    expect(p2.library.to_a.last).to eq(bears.card)
  end

  it "can't target a land" do
    forest = ResolvePermanent("Forest", owner: p2)
    p1.add_mana(blue: 4)
    expect do
      p1.cast(card: Card("Vanish From Sight")) do
        _1.pay_mana(generic: { blue: 3 }, blue: 1).targeting(forest)
      end
    end.to raise_error(StandardError)
  end
end
