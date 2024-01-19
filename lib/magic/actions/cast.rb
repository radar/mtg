module Magic
  module Actions
    class Cast < Action
      extend Forwardable

      class InvalidTarget < StandardError; end

      def_delegators :@card, :enchantment?, :artifact?, :multi_target?
      attr_reader :card, :targets, :value_for_x, :controller, :mode

      def initialize(card:, value_for_x: nil, controller: card.controller, mode: nil, **args)
        super(**args)
        @card = card
        @targets = []
        @value_for_x = value_for_x
        @mode = mode
      end

      def inspect
        "#<Actions::Cast card: #{card.name}, player: #{player.inspect}, mode: #{mode.inspect}>"
      end
      alias_method :name, :inspect

      def countered!
        card.move_to_graveyard!(player)
      end

      def exile!
        card.move_to_exile!
      end

      def mana_cost=(cost)
        @mana_cost = Costs::Mana.new(cost)
      end

      def mana_cost
        @mana_cost ||= begin
          mana_cost_adjustment_abilities = game.battlefield.static_abilities
          .of_type(Abilities::Static::ManaCostAdjustment)
          .applies_to(card)

          cost = mana_cost_adjustment_abilities.each_with_object(card.cost.dup) { |ability, cost| ability.apply(cost) }
          cost.x = value_for_x if value_for_x
          cost
        end
      end

      def auto_pay
        mana_cost.auto_pay(player)
      end

      def kicker_cost
        card.kicker_cost
      end

      def can_perform?
        return false unless card.zone.hand?
        return true if mana_cost.zero?

        mana_cost.can_pay?(player)
      end

      def target_choices
        choices = card.method(:target_choices)
        choices = choices.arity == 1 ? card.target_choices(player) : card.target_choices
      end

      def can_target?(target, index = nil)
        if index
          target_choices[index].include?(target)
        else
          target_choices.include?(target)
        end
      end

      def targeting(*targets)
        if card.respond_to?(:multi_target?) && card.multi_target?
          return multi_target(*targets)
        end

        targets.each do |target|
          raise InvalidTarget, "Invalid target for #{card.name}: #{target}" unless can_target?(target)
        end
        @targets = targets
        self
      end

      def multi_target(*targets)
        targets.each_with_index do |target, index|
          raise InvalidTarget, "Invalid target for #{card.name}: #{target}" unless can_target?(target, index)
        end
        @targets = targets
        self
      end

      def pay_mana(payment)
        mana_cost.pay(player, payment)
        self
      end

      def pay_kicker(payment)
        kicker_cost.pay(player, payment)
      end

      def perform
        mana_cost.finalize!(player)
        game.stack.add(self)

        game.notify!(Events::SpellCast.new(spell: card, player: player))
      end

      def resolve!
        if mode
          resolver = mode.method(:resolve)
        else
          resolver =card.method(:resolve!)
        end

        args = {}
        args[:target] = targets.first if resolver.parameters.include?([:keyreq, :target])
        args[:targets] = targets if resolver.parameters.include?([:keyreq, :targets])
        args[:kicked] = kicker_cost.paid? if resolver.parameters.include?([:key, :kicked])
        args[:value_for_x] = mana_cost.x if resolver.parameters.include?([:keyreq, :value_for_x])

        resolver.call(**args)
      end
    end
  end
end
