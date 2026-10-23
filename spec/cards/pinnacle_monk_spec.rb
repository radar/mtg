# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PinnacleMonk do
  include_context "two player game"

  let(:monk) { Card("Pinnacle Monk", owner: p1) }
  let(:shock) { Card("Lightning Bolt", owner: p1) }
  let(:bears) { Card("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(monk)
  end

  def cast_monk
    p1.add_mana(red: 5)
    p1.cast(card: monk) { _1.pay_mana(generic: { red: 3 }, red: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "is a {3}{R}{R} 2/2 Djinn Monk with prowess and a land back face" do
    expect(monk.mana_value).to eq(5)
    expect(monk.back_face.name).to eq("Mystic Peak")
    expect(monk.back_face).to be_land
  end

  it "returns an instant or sorcery card from your graveyard to your hand" do
    p1.graveyard.add(shock)
    p1.graveyard.add(bears)
    cast_monk

    expect(p1.hand.cards).to include(shock)
    expect(p1.graveyard.cards).to include(bears)
  end

  it "lets you choose among several instants and sorceries" do
    other = Card("Lightning Bolt", owner: p1)
    p1.graveyard.add(shock)
    p1.graveyard.add(other)
    cast_monk

    expect(game.choices.last.choices).to contain_exactly(shock, other)
    game.resolve_choice!(target: other)
    game.settle!

    expect(p1.hand.cards).to include(other)
    expect(p1.graveyard.cards).to include(shock)
  end

  it "does nothing with no instant or sorcery in the graveyard" do
    cast_monk

    expect(game.choices).to be_empty
    expect(p1.creatures.map(&:name)).to include("Pinnacle Monk")
  end

  describe "played as Mystic Peak" do
    let(:peak) { p1.permanents.by_name("Mystic Peak").first }

    it "enters untapped for 3 life, and taps for {R}" do
      p1.play_land(land: monk, face: :back, pay_life: true)

      expect(peak).not_to be_tapped
      expect(p1.life).to eq(17)
      p1.activate_ability(ability: peak.activated_abilities.first)
      expect(p1.mana_pool[:red]).to eq(1)
    end

    it "enters tapped when you do not pay" do
      p1.play_land(land: monk, face: :back)

      expect(peak).to be_tapped
      expect(p1.life).to eq(20)
    end
  end
end
