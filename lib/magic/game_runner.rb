# frozen_string_literal: true

module Magic
  # Roadmap C2c: drives a whole game using each player's `Agent` (`Player#agent`) instead
  # of a caller doing it action-by-action. Built on C2b (`Game#legal_actions`) and A's
  # priority loop, so it needs `Game.new(enforce_priority: true)`.
  #
  # The loop is fully general: drain pending choices, auto-advance no-priority steps
  # (untap, cleanup), otherwise ask whoever holds priority to choose an action (or pass)
  # from `legal_actions`.
  #
  # Preparing a chosen action before performing it is not: `#prepare!` fills in the parts
  # of an action `Game#legal_actions` deliberately leaves blank (see its comment), and it
  # only knows how to do that for --
  #   - `ActivateAbility`/`ActivateManaAbility`'s self-tap/self-sacrifice/self-exile costs
  #     and mana cost (`Player#activate_ability` does the same thing before calling
  #     `take_action`; neither action's own `#perform` pays its costs),
  #   - a mana ability with more than one colour choice on top of that (asks
  #     `Agent#choose_targets`),
  #   - `Cast`'s mana cost, paid from whatever is already floating (`auto_pay_mana`; the
  #     agent chose to activate mana abilities first if it needed to, the same as a real
  #     player would),
  #   - a single-target spell/ability (asks `Agent#choose_targets` for one target from
  #     `target_choices`; modal and multi-target spells are not handled), and
  #   - `Cycle`'s mana cost.
  # Anything else unpaid (a cost needing a chosen target permanent or card, e.g.
  # `Costs::Tap`/`Costs::Sacrifice`/`Costs::Discard`) is left to fail exactly the way it
  # would for a caller that forgot to pay it, since there is no generic cost framework yet
  # (roadmap G3) to prepare it against.
  #
  # A `Choice` (`Stack#choices`) is answered by asking its controller's agent to
  # `#resolve_choice`; only `ScriptedAgent` has anything to say there today (see
  # `Magic::Agent`), so a game that produces a real choice needs one.
  class GameRunner
    class NotFinished < StandardError; end

    def initialize(game:, max_actions: 10_000)
      @game = game
      @max_actions = max_actions
    end

    def call
      max_actions.times do
        return game if game.over?

        step!
      end

      raise NotFinished, "Game#run! did not finish within #{max_actions} actions"
    end

    private

    attr_reader :game, :max_actions

    def step!
      if game.stack.pending_choices?
        resolve_pending_choice!
      elsif game.current_turn.step == "cleanup"
        game.next_turn
      elsif game.priority_player.nil?
        game.current_turn.advance_step!
      else
        take_priority_action!
      end
    end

    def resolve_pending_choice!
      choice = game.stack.choices.first
      answer = agent_for(choice.controller).resolve_choice(game, choice)
      game.resolve_choice!(**answer)
    end

    def take_priority_action!
      player = game.priority_player
      action = agent_for(player).choose_action(game, game.legal_actions(player))

      if action.nil?
        game.pass_priority!
      else
        prepare!(action, agent_for(player))
        game.take_action(action)
      end
    end

    def agent_for(player)
      player.agent || raise("#{player.inspect} has no agent -- set Player#agent before Game#run!")
    end

    def prepare!(action, agent)
      case action
      when Actions::ActivateManaAbility
        prepare_mana_ability_choice!(action, agent)
        prepare_activate_ability!(action, agent)
      when Actions::Cast then prepare_cast!(action, agent)
      when Actions::Cycle then action.mana_cost.auto_pay(player: action.player)
      when Actions::ActivateAbility then prepare_activate_ability!(action, agent)
      end
    end

    # ActivateManaAbility is an ActivateAbility subclass (it resolves immediately instead
    # of using the stack, see #perform), so its costs -- the {T} cost, almost always --
    # need paying and finalizing the same way; #prepare_activate_ability! does that.
    # Neither ActivateAbility#perform nor ActivateManaAbility#perform pays costs
    # themselves -- Player#activate_ability does that before calling Turn#take_action,
    # and this is that same step for an action GameRunner built directly.
    def prepare_mana_ability_choice!(action, agent)
      choices = action.ability.choices
      action.choose(agent.choose_targets(game, choices, count: 1).first) if choices.length > 1
    end

    def prepare_cast!(action, agent)
      prepare_single_target!(action, agent)
      action.auto_pay_mana unless action.mana_cost.zero?
    end

    def prepare_single_target!(action, agent)
      card = action.card
      return unless card.respond_to?(:target_choices)
      return if card.respond_to?(:multi_target?) && card.multi_target?

      targets = Array(action.target_choices)
      action.targeting(agent.choose_targets(game, targets, count: 1).first) unless targets.empty?
    end

    def prepare_activate_ability!(action, agent)
      action.pay_self_tap if action.has_cost?(Costs::SelfTap)
      action.pay_self_sacrifice if action.has_cost?(Costs::SelfSacrifice)
      action.pay_self_exile if action.has_cost?(Costs::SelfExile)
      if action.has_cost?(Costs::Mana)
        action.costs.find { |cost| cost.is_a?(Costs::Mana) }.auto_pay(player: action.player)
      end
      action.finalize_costs!(action.player)
    end
  end
end
