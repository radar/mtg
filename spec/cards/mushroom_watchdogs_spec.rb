# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MushroomWatchdogs do
  include_context "two player game"

  let!(:dogs) { ResolvePermanent("Mushroom Watchdogs", owner: p1) }
  let(:ability) { dogs.activated_abilities.first }

  def food = Magic::Tokens::Food.new(game: game, owner: p1).resolve!

  def activate(fodder)
    p1.activate_ability(ability: ability) { |a| a.pay_sacrifice(fodder) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/2 Dog" do
    expect([dogs.power, dogs.toughness]).to eq([2, 2])
    expect(dogs.type?("Dog")).to eq(true)
  end

  context "at sorcery speed" do
    before { go_to_main_phase! }

    it "sacrifices a Food to gain a +1/+1 counter and vigilance" do
      fodder = food
      expect(dogs).not_to have_keyword(:vigilance)
      activate(fodder)

      expect(p1.permanents.select { _1.type?("Food") }).to be_empty
      expect([dogs.power, dogs.toughness]).to eq([3, 3])
      expect(dogs).to have_keyword(:vigilance)
    end

    it "loses vigilance at end of turn but keeps the counter" do
      activate(food)
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect([dogs.power, dogs.toughness]).to eq([3, 3])
      expect(dogs).not_to have_keyword(:vigilance)
    end

    it "offers only Foods as the sacrifice" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      fodder = food
      cost = ability.costs.find { _1.is_a?(Magic::Costs::Sacrifice) }

      expect(cost.choices).to eq([fodder])
    end

    it "has no Food to sacrifice without one" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      cost = ability.costs.find { _1.is_a?(Magic::Costs::Sacrifice) }

      expect(cost.choices).to be_empty
    end

    it "cannot be activated with the stack non-empty" do
      fodder = food
      p1.add_mana(green: 2)
      p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }

      expect { activate(fodder) }.to raise_error(Magic::IllegalAction, /requirements to activate Mushroom Watchdogs/)
      expect(dogs.power).to eq(2)
    end
  end

  it "cannot be activated outside the main phase" do
    fodder = food

    expect(current_turn.step).to eq("beginning")
    expect { activate(fodder) }.to raise_error(Magic::IllegalAction, /requirements to activate Mushroom Watchdogs/)
    expect(dogs.power).to eq(2)
  end
end
