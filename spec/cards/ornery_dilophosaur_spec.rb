# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::OrneryDilophosaur do
  include_context "two player game"

  subject(:dilophosaur) { ResolvePermanent("Ornery Dilophosaur", owner: p1) }

  it "has deathtouch" do
    expect(dilophosaur.deathtouch?).to eq(true)
  end

  context "when attacking" do
    before do
      dilophosaur
      skip_to_combat!
    end

    context "when the controller does not control a creature with power 4 or greater" do
      let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

      it "does not get +2/+2" do
        current_turn.declare_attackers!
        p1.declare_attacker(attacker: dilophosaur, target: p2)
        current_turn.attackers_declared!
        game.tick!

        expect(dilophosaur.power).to eq(3)
        expect(dilophosaur.toughness).to eq(3)
      end
    end

    context "when the controller controls a creature with power 4 or greater" do
      let!(:colossal_dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }

      it "gets +2/+2 until end of turn" do
        current_turn.declare_attackers!
        p1.declare_attacker(attacker: dilophosaur, target: p2)
        current_turn.attackers_declared!
        game.tick!

        expect(dilophosaur.power).to eq(5)
        expect(dilophosaur.toughness).to eq(5)

        game.current_turn.end!
        game.current_turn.cleanup!
        game.next_turn
        game.tick!

        expect(dilophosaur.power).to eq(3)
        expect(dilophosaur.toughness).to eq(3)
      end
    end
  end
end
