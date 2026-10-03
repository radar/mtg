# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArahboTheFirstFang do
  include_context "two player game"
  before { go_to_main_phase! }

  # Card() wants every word capitalised, including "The".
  def resolve_arahbo(owner: p1) = ResolvePermanent("Arahbo, The First Fang", owner:)

  def cat_tokens(player = p1) = player.creatures.select { _1.name == "Cat" && _1.token? }

  it "is a 2/2 legendary Cat Avatar" do
    arahbo = resolve_arahbo

    expect([arahbo.power, arahbo.toughness]).to eq([2, 2])
    expect(arahbo.type?("Legendary")).to eq(true)
    expect(arahbo.type?("Avatar")).to eq(true)
  end

  it "creates a 1/1 white Cat token when it enters" do
    resolve_arahbo

    expect(cat_tokens.size).to eq(1)
    expect(cat_tokens.first.colors).to eq([:white])
    expect(cat_tokens.first.base_power).to eq(1)
  end

  it "gives other Cats you control +1/+1 but not Arahbo or an opponent's Cats" do
    arahbo = resolve_arahbo
    lions = ResolvePermanent("Savannah Lions", owner: p1) # 2/1 Cat
    opposing = ResolvePermanent("Savannah Lions", owner: p2)

    expect(arahbo.power).to eq(2)
    expect([lions.power, lions.toughness]).to eq([3, 2])
    expect([opposing.power, opposing.toughness]).to eq([2, 1])
    expect(cat_tokens.first.power).to eq(2)
  end

  it "creates another Cat token whenever another nontoken Cat enters under your control" do
    resolve_arahbo
    expect { ResolvePermanent("Savannah Lions", owner: p1) }.to change { cat_tokens.size }.by(1)
  end

  it "does not trigger for a token Cat, a non-Cat, or an opponent's Cat" do
    resolve_arahbo
    lions = ResolvePermanent("Savannah Lions", owner: p1)
    expect do
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Savannah Lions", owner: p2)
      Magic::Permanent.resolve(game:, owner: p1, card: lions.copiable_card, token: true, copy: true, cast: false)
      game.settle!
    end.not_to(change { cat_tokens.size })
  end
end
