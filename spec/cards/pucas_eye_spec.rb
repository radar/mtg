# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PucasEye do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:eye) do
    ResolvePermanent("Puca's Eye", owner: p1).tap { game.resolve_choice!(color: :blue) }
  end

  it "draws a card when it enters, then becomes the chosen color" do
    hand = p1.hand.count
    other = ResolvePermanent("Puca's Eye", owner: p1)
    game.resolve_choice!(color: :red)

    expect(p1.hand.count).to eq(hand + 1)
    expect(other.colors).to eq([:red])
    expect(eye.colors).to eq([:blue])
  end

  it "is colorless before a color is chosen" do
    expect(Card("Puca's Eye", owner: p1).colors).to be_empty
  end

  describe "{3}, {T}: draw a card" do
    def activate
      p1.add_mana(green: 3)
      p1.activate_ability(ability: eye.activated_abilities.first) { _1.pay_mana(generic: { green: 3 }) }
      game.stack.resolve!
    end

    it "can't be activated with fewer than five colors among permanents you control" do
      expect { activate }.to raise_error(Magic::IllegalAction)
    end

    it "draws a card with five colors among permanents you control" do
      allow(p1).to receive(:colors_among_permanents).and_return(5)
      hand = p1.hand.count
      activate

      expect(p1.hand.count).to eq(hand + 1)
      expect(eye).to be_tapped
    end
  end
end
