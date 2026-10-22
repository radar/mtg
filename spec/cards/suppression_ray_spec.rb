# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SuppressionRay do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:ray) { Card("Suppression Ray", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:angel) { ResolvePermanent("Serra Angel", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    p1.hand.items.clear
    p1.hand.add(ray)
  end

  def cast!(target = p2)
    p1.add_mana(white: 5)
    action = cast_action(player: p1, card: ray)
    action.pay_mana(generic: { white: 3 }, white: 2)
    action.targeting(target)
    game.take_action(action)
    game.stack.resolve!
    game.settle!
  end

  def stun_count(permanent) = permanent.counters.of_type(Magic::Counters::Stun).count

  it "has a hybrid cost of {3}{W/U}{W/U} and a land back face" do
    expect(ray.mana_value).to eq(5)
    expect(ray).to be_sorcery
    expect(ray.back_face.name).to eq("Orderly Plaza")
    expect(ray.back_face).to be_land
  end

  it "taps all creatures the target player controls, and none of yours" do
    cast!

    expect(bears).to be_tapped
    expect(angel).to be_tapped
    expect(mine).not_to be_tapped
  end

  it "can target yourself" do
    cast!(p1)

    expect(mine).to be_tapped
    expect(bears).not_to be_tapped
  end

  it "offers no energy payment when you have no energy" do
    cast!

    expect(game.choices).to be_empty
    expect(stun_count(bears)).to eq(0)
  end

  context "with energy" do
    before { p1.add_counter("energy", amount: 3) }

    it "pays that much energy and stuns up to that many creatures tapped this way" do
      cast!
      expect(game.choices.first).to be_a(described_class::PayChoice)
      game.resolve_choice!(amount: 1)
      expect(game.choices.first).to be_a(described_class::StunChoice)
      game.resolve_choice!(creatures: [angel])

      expect(p1.energy).to eq(2)
      expect(stun_count(angel)).to eq(1)
      expect(stun_count(bears)).to eq(0)
    end

    it "rejects choosing more creatures than energy paid" do
      cast!
      game.resolve_choice!(amount: 1)

      expect { game.resolve_choice!(creatures: [angel, bears]) }.to raise_error(ArgumentError, /at most 1/)
    end

    it "rejects a creature that was not tapped this way" do
      cast!
      game.resolve_choice!(amount: 2)

      expect { game.resolve_choice!(creatures: [mine]) }.to raise_error(ArgumentError, /tapped this way/)
    end

    it "does nothing more when you pay nothing" do
      cast!
      game.skip_choice!

      expect(game.choices).to be_empty
      expect(p1.energy).to eq(3)
      expect(stun_count(angel)).to eq(0)
    end

    it "lets you choose no creatures after paying" do
      cast!
      game.resolve_choice!(amount: 2)
      game.skip_choice!

      expect(p1.energy).to eq(1)
      expect(stun_count(angel)).to eq(0)
      expect(stun_count(bears)).to eq(0)
    end

    it "does not offer creatures that were already tapped" do
      bears.tap!
      cast!
      game.resolve_choice!(amount: 2)

      expect(game.choices.first.choices).to eq([angel])
    end
  end

  context "played as Orderly Plaza" do
    before { p1.play_land(land: ray, face: :back) }

    let(:plaza) { p1.permanents.by_name("Orderly Plaza").first }

    it "enters tapped as a land" do
      expect(plaza).to be_land
      expect(plaza).to be_tapped
    end

    it "taps for {W} or {U}" do
      plaza.untap!
      p1.activate_ability(ability: plaza.activated_abilities.first) { _1.choose(:white) }
      expect(p1.mana_pool[:white]).to eq(1)
      plaza.untap!
      p1.activate_ability(ability: plaza.activated_abilities.first) { _1.choose(:blue) }
      expect(p1.mana_pool[:blue]).to eq(1)
    end
  end
end
