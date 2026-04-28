# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThrashingBrontodon do
  include_context "two player game"

  subject(:brontodon) { ResolvePermanent("Thrashing Brontodon", owner: p1) }

  it "is a 3/4 Dinosaur" do
    expect(brontodon.power).to eq(3)
    expect(brontodon.toughness).to eq(4)
  end

  context "activated ability: destroy target artifact or enchantment" do
    let(:ability) { brontodon.activated_abilities.first }

    context "targeting an artifact" do
      let!(:great_furnace) { ResolvePermanent("Great Furnace", owner: p2) }

      it "destroys the artifact and sacrifices itself" do
        p1.add_mana(green: 1)
        p1.activate_ability(ability: ability) do
          _1.pay_mana(generic: { green: 1 })
          _1.targeting(great_furnace)
        end

        game.stack.resolve!
        game.tick!

        expect(great_furnace.zone).to be_nil
        expect(brontodon.zone).to be_nil
      end
    end

    context "targeting an enchantment" do
      let!(:rhystic_study) { ResolvePermanent("Rhystic Study", owner: p2) }

      it "destroys the enchantment and sacrifices itself" do
        p1.add_mana(green: 1)
        p1.activate_ability(ability: ability) do
          _1.pay_mana(generic: { green: 1 })
          _1.targeting(rhystic_study)
        end

        game.stack.resolve!
        game.tick!

        expect(rhystic_study.zone).to be_nil
        expect(brontodon.zone).to be_nil
      end
    end
  end
end
