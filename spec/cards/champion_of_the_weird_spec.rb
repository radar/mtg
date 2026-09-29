# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChampionOfTheWeird do
  include_context "two player game"

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  let(:card) { Card("Champion Of The Weird", owner: p1) }

  it "is a 5/5 Goblin Berserker" do
    weird = ResolvePermanent("Champion Of The Weird", owner: p1)
    expect([weird.power, weird.toughness]).to eq([5, 5])
    expect(weird.type?("Goblin")).to eq(true)
  end

  it "exiles a Goblin as it is cast and returns it to hand when it leaves" do
    goblin = ResolvePermanent("Mogg Fanatic", owner: p1)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(black: 4)
    p1.cast(card: card) { |a| a.pay_mana(generic: { black: 3 }, black: 1).pay_behold(goblin) }
    game.stack.resolve!
    expect(goblin.card.zone).to be_exile

    p1.creatures.find { _1.card == card }.destroy!
    game.settle!
    expect(goblin.card.zone).to be_hand
  end

  describe "the blight ability" do
    let!(:weird) { ResolvePermanent("Champion Of The Weird", owner: p1) }
    let!(:own_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:rival_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    before { go_to_main_phase! }

    def activate
      p1.activate_ability(ability: weird.activated_abilities.first) do |ability|
        ability.targeting(p2)
        ability.pay_blight(own_bears)
      end
      game.stack.resolve!
    end

    it "pays 1 life and blights 2 to make an opponent blight 2" do
      activate
      expect(p1.life).to eq(19)
      expect(minus_counters(own_bears)).to eq(2)

      expect(game.choices.last).to be_a(Magic::Choice::Blight)
      expect(game.choices.last.player).to eq(p2)
      game.resolve_choice!(target: rival_bears)
      expect(minus_counters(rival_bears)).to eq(2)
    end

    it "asks for nothing when the opponent has no creature" do
      rival_bears.destroy!
      activate
      expect(game.choices).to be_empty
    end

    it "can only be activated as a sorcery" do
      game.next_turn
      go_to_main_phase!
      expect(weird.activated_abilities.first.requirements_met?).to eq(false)
    end

    it "can't be activated with 0 life" do
      p1.lose_life(20)
      expect(Magic::Costs::PayLife.new(weird, amount: 1).can_pay?(p1)).to eq(false)
    end
  end
end
