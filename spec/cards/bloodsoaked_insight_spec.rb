# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BloodsoakedInsight do
  include_context "two player game"

  let(:insight) { Card("Bloodsoaked Insight", owner: p1) }
  let!(:bears) { Card("Grizzly Bears", owner: p2).tap { p2.library.add(_1) } }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(insight)
  end

  def cast_insight!(mana: 7)
    p1.add_mana(black: mana)
    p1.cast(card: insight) do |action|
      action.pay_mana(generic: { black: mana - 2 }, black: 2).targeting(p2)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a {5}{B/R}{B/R} sorcery with a land back face" do
    expect(insight.mana_value).to eq(7)
    expect(insight).to be_sorcery
    expect(insight.back_face.name).to eq("Sanguine Morass")
    expect(insight.back_face).to be_land
  end

  it "only targets opponents" do
    expect(insight.target_choices.to_a).to eq([p2])
  end

  it "makes the target opponent exile the top three cards of their library" do
    top_three = p2.library.take(3)
    before_count = p2.library.count
    cast_insight!

    expect(top_three.map(&:zone)).to all(be_exile)
    expect(p2.library.count).to eq(before_count - 3)
  end

  it "costs {1} less for each life your opponents lost this turn" do
    p2.lose_life(3)
    before_count = p2.library.count
    cast_insight!(mana: 4)

    expect(p2.library.count).to eq(before_count - 3)
  end

  it "can't be cast for less without life loss" do
    expect { cast_insight!(mana: 4) }.to raise_error(StandardError)
  end

  it "lets you play the exiled cards, spending mana of any type on spells" do
    cast_insight!
    p1.add_mana(red: 2)
    p1.cast(card: bears) { |action| action.pay_mana(generic: { red: 1 }, red: 1) }
    game.stack.resolve!
    game.settle!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end

  describe "played as Sanguine Morass" do
    let(:morass) { p1.permanents.by_name("Sanguine Morass").first }

    before { p1.play_land(land: insight, face: :back) }

    it "enters tapped" do
      expect(morass).to be_land
      expect(morass).to be_tapped
    end

    it "taps for {B}" do
      morass.untap!
      p1.activate_ability(ability: morass.activated_abilities.first) { _1.choose(:black) }
      expect(p1.mana_pool[:black]).to eq(1)
    end

    it "taps for {R}" do
      morass.untap!
      p1.activate_ability(ability: morass.activated_abilities.first) { _1.choose(:red) }
      expect(p1.mana_pool[:red]).to eq(1)
    end
  end
end
