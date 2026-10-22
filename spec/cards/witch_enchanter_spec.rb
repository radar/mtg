# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WitchEnchanter do
  include_context "two player game"

  let(:enchanter) { Card("Witch Enchanter", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(enchanter)
  end

  def cast_enchanter
    p1.add_mana(white: 4)
    p1.cast(card: enchanter) { _1.pay_mana(generic: { white: 3 }, white: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a {3}{W} 2/2 Human Warlock with a land back face" do
    expect(enchanter.mana_value).to eq(4)
    expect(enchanter).to be_creature
    expect(enchanter.back_face.name).to eq("Witch-Blessed Meadow")
    expect(enchanter.back_face).to be_land
  end

  describe "enters the battlefield" do
    let!(:their_ring) { ResolvePermanent("Sol Ring", owner: p2) }
    let!(:their_levy) { ResolvePermanent("Charitable Levy", owner: p2) }
    let!(:my_ring) { ResolvePermanent("Sol Ring", owner: p1) }

    before { cast_enchanter }

    it "is a 2/2" do
      permanent = p1.permanents.by_name("Witch Enchanter").first
      expect([permanent.power, permanent.toughness]).to eq([2, 2])
    end

    it "only offers artifacts and enchantments an opponent controls" do
      expect(game.choices.last.choices).to contain_exactly(their_ring, their_levy)
    end

    it "destroys the chosen artifact" do
      game.resolve_choice!(target: their_ring)
      game.settle!

      expect(p2.artifacts).to be_empty
      expect(p2.enchantments).to include(their_levy)
      expect(p1.artifacts).to include(my_ring)
    end

    it "destroys the chosen enchantment" do
      game.resolve_choice!(target: their_levy)
      game.settle!

      expect(p2.enchantments).to be_empty
      expect(p2.artifacts).to include(their_ring)
    end
  end

  it "does nothing without a target" do
    cast_enchanter

    expect(game.choices).to be_empty
    expect(p1.creatures.map(&:name)).to include("Witch Enchanter")
  end

  describe "played as Witch-Blessed Meadow" do
    let(:meadow) { p1.permanents.by_name("Witch-Blessed Meadow").first }

    context "paying 3 life" do
      before { p1.play_land(land: enchanter, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(meadow).to be_land
        expect(meadow).not_to be_tapped
        expect(p1.life).to eq(17)
      end

      it "taps for {W}" do
        p1.activate_ability(ability: meadow.activated_abilities.first)
        expect(p1.mana_pool[:white]).to eq(1)
      end
    end

    context "not paying life" do
      before { p1.play_land(land: enchanter, face: :back) }

      it "enters tapped, with no life lost" do
        expect(meadow).to be_tapped
        expect(p1.life).to eq(20)
      end
    end
  end
end
