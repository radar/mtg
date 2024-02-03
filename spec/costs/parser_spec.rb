require "spec_helper"

RSpec.describe Magic::Costs::Parser do
  let(:controller) { instance_double(Magic::Player) }
  let(:source) { instance_double(Magic::Card, controller: controller) }
  it "parses {2} into two generic mana cost" do
    costs = Magic::Costs::Parser.parse(source:, costs: "{2}")
    cost = costs.first
    expect(cost.generic).to eq(2)
  end

  it "parses {W} into white mana cost" do
    costs = Magic::Costs::Parser.parse(source:, costs: "{W}")
    cost = costs.first
    expect(cost.white).to eq(1)
  end

  it "parses {T} into a self-tap cost" do
    costs = Magic::Costs::Parser.parse(source:, costs: "{T}")
    cost = costs.first
    expect(cost).to be_a(Magic::Costs::SelfTap)
  end

  context "combined costs" do
    before do
      allow(controller).to receive(:creatures).and_return([])
    end

    it "parses mana, tap and sacrifice" do
      costs = Magic::Costs::Parser.parse(source:, costs: "{W}{B}, {T}, Sacrifice a creature")
      expect(costs[0].white).to eq(1)
      expect(costs[0].black).to eq(1)
      expect(costs[1]).to be_a(Magic::Costs::SelfTap)
      expect(costs[2]).to be_a(Magic::Costs::Sacrifice)
    end
  end
end
