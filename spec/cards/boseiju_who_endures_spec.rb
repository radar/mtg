require "spec_helper"

RSpec.describe Magic::Cards::BoseijuWhoEndures do
  include_context "two player game"

  let!(:boseiju) { Card("Boseiju, Who Endures", owner: p1).tap { |card| p1.hand.add(card) } }
  let(:ability) { boseiju.hand_abilities.first }

  def channel(target)
    p1.activate_ability(ability: ability) do |action|
      action.targeting(target)
      action.pay_mana(generic: { green: 1 }, green: 1)
    end
    game.stack.resolve!
  end

  before { p1.add_mana(green: 2) }

  it "destroys a target nonbasic land, discarding itself" do
    land = ResolvePermanent("Boseiju, Who Endures", owner: p2)
    channel(land)

    expect(p2.permanents).not_to include(land)
    expect(p1.graveyard.cards).to include(boseiju)
  end

  it "only targets an artifact, enchantment or nonbasic land an opponent controls" do
    ResolvePermanent("Forest", owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Boseiju, Who Endures", owner: p1)
    land = ResolvePermanent("Boseiju, Who Endures", owner: p2)

    expect(ability.target_choices.to_a).to eq([land])
  end

  it "lets the opponent search for a basic land" do
    p2.library.add(Card("Forest", owner: p2))
    land = ResolvePermanent("Boseiju, Who Endures", owner: p2)
    channel(land)

    expect(game.choices.last.controller).to eq(p2)
  end

  it "costs {1} less for each legendary creature you control" do
    expect(ability.costs.first.cost).to eq(generic: 1, green: 1)

    legend = ResolvePermanent("Grizzly Bears", owner: p1)
    allow(legend).to receive(:legendary?).and_return(true)
    expect(ability.costs.first.cost).to eq(green: 1)
  end

  it "can't be activated from the battlefield" do
    permanent = ResolvePermanent("Boseiju, Who Endures", owner: p1)
    expect(permanent.card.hand_abilities.first.requirements_met?).to be(false)
  end
end
