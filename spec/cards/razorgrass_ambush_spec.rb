# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RazorgrassAmbush do
  include_context "two player game"

  let(:ambush) { Card("Razorgrass Ambush", owner: p2) }
  let!(:attacker) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:blocker) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:bystander) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    p2.hand.add(ambush)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
  end

  def cast!(target)
    p2.add_mana(white: 2)
    action = cast_action(player: p2, card: ambush)
    action.pay_mana(generic: { white: 1 }, white: 1)
    action.targeting(target)
    game.take_action(action)
    game.stack.resolve!
    game.settle!
  end

  it "is a {1}{W} instant with a land back face" do
    expect(ambush.mana_value).to eq(2)
    expect(ambush).to be_instant
    expect(ambush.back_face.name).to eq("Razorgrass Field")
    expect(ambush.back_face).to be_land
  end

  it "targets only attacking creatures before blockers are declared" do
    expect(ambush.target_choices).to contain_exactly(attacker)
  end

  it "targets attacking and blocking creatures" do
    p2.declare_blocker(blocker: blocker, attacker: attacker)

    expect(ambush.target_choices).to contain_exactly(attacker, blocker)
  end

  it "deals 3 damage to an attacking creature" do
    cast!(attacker)

    expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "deals 3 damage to a blocking creature" do
    p2.declare_blocker(blocker: blocker, attacker: attacker)
    cast!(blocker)

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(bystander.zone).to be_battlefield
  end

  describe "played as Razorgrass Field" do
    let(:field) { p2.permanents.by_name("Razorgrass Field").first }

    before { go_to_main_phase_for!(p2) }

    context "paying 3 life" do
      before { p2.play_land(land: ambush, face: :back, pay_life: true) }

      it "enters untapped, costing 3 life" do
        expect(field).to be_land
        expect(field).not_to be_tapped
        expect(p2.life).to eq(17)
      end

      it "taps for {W}" do
        p2.activate_ability(ability: field.activated_abilities.first)
        expect(p2.mana_pool[:white]).to eq(1)
      end
    end

    context "not paying life" do
      before { p2.play_land(land: ambush, face: :back) }

      it "enters tapped, with no life lost" do
        expect(field).to be_tapped
        expect(p2.life).to eq(20)
      end
    end
  end
end
