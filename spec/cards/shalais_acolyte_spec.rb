require 'spec_helper'

RSpec.describe Magic::Cards::ShalaisAcolyte do
  include_context "two player game"

  subject { Card("Shalai's Acolyte") }

  context "resolution" do
    it "kicker cost paid" do
      p1.add_mana(white: 6, green: 1)
      action = cast_action(card: subject, player: p1)
      action.pay_mana(white: 1, generic: { white: 4 })
      action.pay_kicker(generic: { white: 1 }, green: 1)
      game.take_action(action)
      game.stack.resolve!

      permanent = p1.creatures.by_name("Shalai's Acolyte").first
      expect(permanent.power).to eq(5)
      expect(permanent.toughness).to eq(6)
      expect(permanent.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    end

    it "kicker cost not paid" do
      p1.add_mana(white: 5)
      action = cast_action(card: subject, player: p1)
      action.pay_mana(white: 1, generic: { white: 4 })
      game.take_action(action)
      game.stack.resolve!

      permanent = p1.creatures.by_name("Shalai's Acolyte").first
      expect(permanent.power).to eq(3)
      expect(permanent.toughness).to eq(4)
    end
  end
end
