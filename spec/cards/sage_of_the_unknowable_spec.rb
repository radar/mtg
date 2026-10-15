# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SageOfTheUnknowable do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:sage) { ResolvePermanent("Sage Of The Unknowable", owner: p1) }

  def tap_sage
    p1.activate_ability(ability: sage.activated_abilities.first)
  end

  it "is a 0/4" do
    expect([sage.power, sage.toughness]).to eq([0, 4])
  end

  it "taps for restricted colorless mana" do
    tap_sage
    expect(sage).to be_tapped
    expect(p1.restricted_mana.map(&:color)).to eq([:colorless])
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "pays for a colorless spell" do
    tap_sage
    ring = Card("Sol Ring", owner: p1)
    p1.hand.add(ring)
    p1.cast(card: ring) { |a| a.pay_mana(generic: { colorless: 1 }) }
    expect(p1.restricted_mana).to be_empty
    game.stack.resolve!
    expect(game.battlefield.map(&:name)).to include("Sol Ring")
  end

  it "cannot pay for a colored spell" do
    tap_sage
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    action = Magic::Actions::Cast.new(card: bears, player: p1, game: game)
    expect(action.mana_cost.can_pay?(p1)).to eq(false)
  end

  it "pays to activate an ability" do
    curator = ResolvePermanent("Keen Eyed Curator", owner: p1)
    target = Card("Grizzly Bears", owner: p2)
    p2.graveyard.add(target)
    tap_sage
    p1.activate_ability(ability: curator.activated_abilities.first) do
      _1.targeting(target)
      _1.pay_mana(generic: { colorless: 1 })
    end
    expect(p1.restricted_mana).to be_empty
  end

  it "pays to activate an ability from hand (channel)" do
    boseiju = Card("Boseiju, Who Endures", owner: p1)
    p1.hand.add(boseiju)
    land = ResolvePermanent("Boseiju, Who Endures", owner: p2)
    p1.add_mana(green: 1)
    tap_sage
    p1.activate_ability(ability: boseiju.hand_abilities.first) do |action|
      action.targeting(land)
      action.pay_mana(generic: { colorless: 1 }, green: 1)
    end
    expect(p1.restricted_mana).to be_empty
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "pays for cycling" do
    soarer = Card("Stratosoarer", owner: p1)
    p1.hand.add(soarer)
    p1.add_mana(blue: 1)
    tap_sage
    p1.cycle(card: soarer) { _1.pay_mana(generic: { colorless: 1 }, blue: 1) }
    expect(p1.restricted_mana).to be_empty
    expect(soarer.zone).to be_graveyard
  end

  it "pays for ninjutsu" do
    ninja = Card("Kaito Bane Of Nightmares", owner: p1)
    p1.hand.add(ninja)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    p1.add_mana(blue: 1, black: 1)
    tap_sage
    p1.ninjutsu(card: ninja, attacker: bears) { _1.pay_mana(generic: { colorless: 1 }, blue: 1, black: 1) }
    expect(p1.restricted_mana).to be_empty
  end

  it "does not pay for suspend, which is neither a spell nor an ability" do
    spell = Card("Suspended Sentence", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(black: 1)
    tap_sage
    expect {
      p1.suspend(card: spell) { _1.pay_mana(generic: { colorless: 1 }, black: 1) }
    }.to raise_error(Magic::Costs::Mana::CannotPay)
  end

  it "refuses a suspended colorless card too" do
    ring = Card("Sol Ring", owner: p1)
    use = Magic::Actions::Suspend::Use.new(card: ring)
    expect(Magic::ManaRestriction::ColorlessSpellOrAbility.new.permits?(use)).to be(false)
  end
end
