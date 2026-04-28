# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::QuillBladeLaureate do
  include_context "two player game"

  let!(:permanent) { ResolvePermanent("Quill-Blade Laureate", owner: p1) }

  it "enters prepared" do
    expect(permanent).to be_prepared
  end

  it "has double strike" do
    expect(permanent).to be_double_strike
  end

  describe "Cast Twofold Intent" do
    let(:target) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let(:ability) { permanent.activated_abilities.first }

    context "when prepared and has mana" do
      before { p1.add_mana(white: 2) }

      it "can be activated" do
        action = p1.prepare_activate_ability(ability: ability)
        expect(action.can_be_activated?(p1)).to eq(true)
      end

      it "gives target +1/+0 until end of turn" do
        original_power = target.power
        p1.activate_ability(ability: ability) do
          _1.targeting(target).pay_mana(generic: { white: 1 }, white: 1)
        end
        game.stack.resolve!
        game.tick!
        expect(target.power).to eq(original_power + 1)
      end

      it "gives target double strike until end of turn" do
        p1.activate_ability(ability: ability) do
          _1.targeting(target).pay_mana(generic: { white: 1 }, white: 1)
        end
        game.stack.resolve!
        game.tick!
        expect(target).to be_double_strike
      end

      it "unprepares after activation" do
        p1.activate_ability(ability: ability) do
          _1.targeting(target).pay_mana(generic: { white: 1 }, white: 1)
        end
        game.stack.resolve!
        expect(permanent).not_to be_prepared
      end
    end

    context "when not prepared" do
      before { permanent.unprepare! }

      it "cannot be activated" do
        action = p1.prepare_activate_ability(ability: ability)
        expect(action.can_be_activated?(p1)).to eq(false)
      end
    end

    context "when prepared but no mana" do
      it "cannot be activated" do
        action = p1.prepare_activate_ability(ability: ability)
        expect(action.can_be_activated?(p1)).to eq(false)
      end
    end
  end
end
