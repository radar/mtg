# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IzzetGeneratorium do
  include_context "two player game"

  let!(:generatorium) { ResolvePermanent("Izzet Generatorium", owner: p1) }

  def draw_ability = generatorium.activated_abilities.first

  it "makes you get one extra energy each time you would get energy" do
    ResolvePermanent("Tempest Harvester", owner: p1)

    expect(p1.energy).to eq(3)
  end

  it "adds one for a single energy too" do
    ResolvePermanent("Phyrexian Ironworks", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: ResolvePermanent("Grizzly Bears", owner: p1), target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(p1.energy).to eq(2)
  end

  it "doesn't affect an opponent's energy" do
    ResolvePermanent("Tempest Harvester", owner: p2)

    expect(p2.energy).to eq(2)
  end

  it "doesn't add energy when you get none" do
    expect(p1.energy).to eq(0)
  end

  context "activated ability" do
    before { go_to_main_phase! }

    it "can't draw before four energy has been paid this turn" do
      ResolvePermanent("Tempest Harvester", owner: p1)
      p1.pay_energy!(3)

      expect { p1.activate_ability(ability: draw_ability) }.to raise_error(Magic::IllegalAction)
    end

    it "draws a card once four or more energy has been paid this turn" do
      ResolvePermanent("Tempest Harvester", owner: p1)
      p1.add_counter("energy", amount: 2)
      p1.pay_energy!(4)
      hand = p1.hand.count

      p1.activate_ability(ability: draw_ability)
      game.stack.resolve!
      game.settle!

      expect(p1.hand.count).to eq(hand + 1)
      expect(generatorium).to be_tapped
    end

    it "counts energy paid across several payments" do
      p1.add_counter("energy", amount: 4)
      p1.pay_energy!(2)
      p1.pay_energy!(2)
      hand = p1.hand.count

      p1.activate_ability(ability: draw_ability)
      game.stack.resolve!
      game.settle!

      expect(p1.hand.count).to eq(hand + 1)
    end

    it "forgets the payments on a later turn" do
      p1.add_counter("energy", amount: 4)
      p1.pay_energy!(4)
      2.times { game.next_turn }
      go_to_main_phase!

      expect { p1.activate_ability(ability: draw_ability) }.to raise_error(Magic::IllegalAction)
    end
  end
end
