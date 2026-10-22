# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RoilCartographer do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:cartographer) { ResolvePermanent("Roil Cartographer", owner: p1) }

  def play_forest(player = p1)
    forest = Card("Forest", owner: player)
    player.hand.add(forest)
    player.play_land(land: forest)
    game.settle!
  end

  def draw_ability = cartographer.activated_abilities.first

  it "is a 1/3 Merfolk Rogue" do
    expect([cartographer.power, cartographer.toughness]).to eq([1, 3])
    expect(cartographer.type?("Merfolk")).to be(true)
    expect(cartographer.type?("Rogue")).to be(true)
  end

  context "landfall" do
    it "gives you an energy when a land you control enters" do
      play_forest

      expect(p1.energy).to eq(1)
    end

    it "doesn't trigger for a land an opponent controls" do
      ResolvePermanent("Forest", owner: p2)
      game.settle!

      expect(p1.energy).to eq(0)
    end

    it "doesn't trigger for a nonland permanent" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.settle!

      expect(p1.energy).to eq(0)
    end
  end

  context "{T}, pay six {E}: draw three cards" do
    before { p1.add_counter("energy", amount: 7) }

    it "taps, pays six energy and draws three cards" do
      expect { p1.activate_ability(ability: draw_ability); game.stack.resolve!; game.settle! }
        .to change { p1.hand.count }.by(3)

      expect(p1.energy).to eq(1)
      expect(cartographer).to be_tapped
    end

    it "can't be activated with fewer than six energy" do
      p1.pay_energy!(2)

      expect { p1.activate_ability(ability: draw_ability) }.to raise_error(RuntimeError, /can't pay 6 \{E\}/)
      expect(p1.energy).to eq(5)
    end

    it "can't be activated while tapped" do
      cartographer.tap!

      expect { p1.activate_ability(ability: draw_ability) }.to raise_error(StandardError)
      expect(p1.energy).to eq(7)
    end
  end
end
