require "spec_helper"

RSpec.describe "Trigger queue (Game#queue_triggers?)" do
  include_context "two player game"

  # Wolverine Riders' upkeep trigger has no `you?` restriction, so it fires for
  # whoever's upkeep it is, and its effect (creating a token) is easy to observe. Its
  # own "another Elf enters" trigger also fires off that token (a real, expected
  # nested-trigger case), so draining to quiescence needs a loop, not one resolve!.
  def settle!
    loop do
      game.check_state_based_actions!
      if game.stack.pending_choices?
        choice = game.choices.first
        game.resolve_choice!(target: choice.target_choices.first)
      elsif !game.stack.empty?
        game.stack.resolve!
      else
        break
      end
    end
  end

  describe "with queue_triggers: true" do
    let(:game) { Magic::Game.new(queue_triggers: true) }

    it "defers a triggered ability's effect until the stack resolves, in APNAP order" do
      ResolvePermanent("Wolverine Riders", owner: p1)
      ResolvePermanent("Wolverine Riders", owner: p2)
      settle!

      current_turn.untap!
      current_turn.upkeep!

      expect(game.battlefield.creatures.count(&:token?)).to eq(0)
      game.state_based_actions_checkpoint!
      expect(game.stack.first.controller).to eq(p2)

      settle!

      expect(game.battlefield.creatures.count(&:token?)).to eq(2)
    end

    it "lets a player order their own simultaneous triggers" do
      ResolvePermanent("Wolverine Riders", owner: p1)
      ResolvePermanent("Wolverine Riders", owner: p1)
      settle!

      current_turn.untap!
      current_turn.upkeep!
      game.state_based_actions_checkpoint!

      expect(game.stack).to be_empty
      expect(game.choices.count).to eq(1)

      choice = game.choices.first
      expect(choice).to be_a(Magic::Choice::OrderTriggers)
      expect(choice.triggers.count).to eq(2)

      first, second = choice.triggers
      game.resolve_choice!(target: first)

      # The remaining single trigger auto-resolves onto the stack too.
      expect(game.choices).to be_empty
      expect(game.stack.count).to eq(2)
      expect(game.stack.map(&:controller)).to eq([p1, p1])

      settle!

      expect(game.battlefield.creatures.count(&:token?)).to eq(2)
    end
  end

  describe "with the default (queue_triggers: false)" do
    it "keeps running triggers synchronously, with no stack involvement" do
      ResolvePermanent("Wolverine Riders", owner: p1)

      current_turn.untap!
      current_turn.upkeep!

      expect(game.battlefield.creatures.count(&:token?)).to eq(1)
      expect(game.stack).to be_empty
    end
  end
end
