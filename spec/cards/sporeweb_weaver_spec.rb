# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::SporewebWeaver do
  include_context "two player game"

  subject! { ResolvePermanent("Sporeweb Weaver", owner: p1) }

  it "has reach" do
    expect(subject).to have_keyword(Magic::Cards::Keywords::REACH)
  end

  it "has hexproof from blue" do
    expect(subject.hexproof_from?(:blue)).to be(true)
  end

  context "when Sporeweb Weaver is dealt damage" do
    let(:attacker) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      game.add_effect(
        Magic::Effects::DealDamage.new(
          source: attacker,
          target: subject,
          damage: 1,
        )
      )
    end

    it "gains 1 life for the controller" do
      expect(p1.life).to eq(p1.starting_life + 1)
    end

    it "creates a 1/1 green Saproling token" do
      saprolings = game.battlefield.creatures.select { |c| c.type?("Saproling") }
      expect(saprolings.count).to eq(1)
      expect(saprolings.first.power).to eq(1)
      expect(saprolings.first.toughness).to eq(1)
    end
  end

  context "when another creature is dealt damage" do
    let(:other_creature) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let(:attacker) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before do
      game.add_effect(
        Magic::Effects::DealDamage.new(
          source: attacker,
          target: other_creature,
          damage: 1,
        )
      )
    end

    it "does not gain life" do
      expect(p1.life).to eq(p1.starting_life)
    end

    it "does not create a Saproling token" do
      saprolings = game.battlefield.creatures.select { |c| c.type?("Saproling") }
      expect(saprolings.count).to eq(0)
    end
  end
end
