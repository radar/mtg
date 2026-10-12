require 'spec_helper'

RSpec.describe Magic::Cards::ReflectingPool do
  include_context "two player game"

  let(:pool) { ResolvePermanent("Reflecting Pool", owner: p1) }

  it "produces nothing alone" do
    expect(pool.activated_abilities.first.choices).to be_empty
  end

  it "produces what other lands could" do
    ResolvePermanent("Forest", owner: p1)
    expect(pool.activated_abilities.first.choices).to eq([:green])
  end

  it "does not recurse with two pools" do
    ResolvePermanent("Forest", owner: p1)
    other = ResolvePermanent("Reflecting Pool", owner: p1)
    expect(pool.activated_abilities.first.choices).to eq([:green])
    expect(other.activated_abilities.first.choices).to eq([:green])
  end

  context "with a reflecting ability of a different kind on another land" do
    let(:orchard_ability) do
      Class.new(Magic::TapManaAbility) do
        def reflects_other_lands? = true

        def choices
          controller.lands.flat_map(&:activated_abilities)
            .select { |ability| ability.is_a?(Magic::ManaAbility) }
            .reject(&:reflects_other_lands?)
            .flat_map(&:choices).uniq
        end
      end
    end

    it "does not recurse" do
      ResolvePermanent("Forest", owner: p1)
      orchard = ResolvePermanent("Forest", owner: p1)
      orchard.activated_abilities = [orchard_ability.new(source: orchard)]
      expect(pool.activated_abilities.first.choices).to eq([:green])
    end
  end
end
