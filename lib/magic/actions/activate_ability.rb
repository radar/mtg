module Magic
  module Actions
    class ActivateAbility < Action
      attr_reader :ability, :costs, :targets, :sacrificed, :tapped

      def initialize(ability:, **args)
        @ability = ability
        @costs = @ability.costs
        # So restricted mana ("spend only on abilities of Elemental sources") counts wherever
        # these costs are checked or paid: `legal_actions`, `#pay`, or `GameRunner`.
        @costs.each { |cost| cost.for_use = AbilityUse.new(source: @ability.source, mana_cost: cost) if cost.is_a?(Costs::Mana) }
        @targets = []
        super(**args)
      end

      def inspect
        "#<Actions::Actions::ActivateAbility source: #{ability.source.name}, ability: #{ability.class}>"
      end

      def can_be_activated?(player)
        costs.all? { |cost| cost.can_pay?(player) } && @ability.requirements_met? && !@ability.activation_limit_reached?
      end

      def name
        ability
      end

      def illegal_reason
        source = ability.source
        return "#{player.inspect} does not control #{source.name}" if source.respond_to?(:controller) && source.controller != player
        return "#{source.name}'s ability cannot be activated" if source.respond_to?(:can_activate_ability?) && !source.can_activate_ability?(ability)
        return "#{source.name}'s ability can only be activated once each turn" if ability.activation_limit_reached?

        return "#{source.name}'s ability can't be activated" if activation_prevented?

        "the requirements to activate #{source.name}'s ability are not met" unless @requirements_verified || ability.requirements_met?
      end

      # A battlefield static ability answering `prevents_activation?(ability)` stops non-mana abilities from being
      # activated ("Activated abilities of sources with the chosen name can't be activated unless they're mana abilities").
      def activation_prevented?
        return false if ability.is_a?(Magic::ManaAbility)

        game.battlefield.static_abilities.any? { |static| static.respond_to?(:prevents_activation?) && static.prevents_activation?(ability) }
      end

      # Activation restrictions ("Activate only if you control five or more lands") are checked as the ability is
      # proposed (rule 602.5b), before costs such as sacrificing the source are paid. `Player#activate_ability`
      # calls this first; afterwards `illegal_reason` doesn't check them again.
      def verify_requirements!
        source = ability.source
        if source.respond_to?(:controller) && source.controller != player
          raise Magic::IllegalAction.new(self, "#{player.inspect} does not control #{source.name}")
        end

        raise Magic::IllegalAction.new(self, "#{source.name}'s ability can't be activated") if activation_prevented?
        raise Magic::IllegalAction.new(self, "the requirements to activate #{ability.source.name}'s ability are not met") unless ability.requirements_met?

        @requirements_verified = true
      end

      def valid_targets?(*targets)
        ability.valid_targets?(*targets)
      end

      def targeting(*targets)
        raise "Invalid target specified for #{ability}: #{targets}" unless valid_targets?(*targets)
        @targets = targets
        apply_target_cost_reductions!
        self
      end

      # "Equip abilities you activate that target this creature cost {2} less to activate" (Dwarven Mauler): a
      # battlefield static ability answering `activation_cost_reduction_for_targets(ability, targets, player)` with
      # the generic mana to take off. Only known once the targets are, so call `targeting` before paying.
      def apply_target_cost_reductions!
        mana = costs.find { |cost| cost.is_a?(Costs::Mana) }
        return unless mana

        reduction = game.battlefield.static_abilities
          .select { |static| static.respond_to?(:activation_cost_reduction_for_targets) }
          .sum { |static| static.activation_cost_reduction_for_targets(ability, targets, player) }
        change = reduction - (@target_cost_reduction || 0)
        return if change.zero?

        mana.adjusted_by(generic: -change)
        @target_cost_reduction = reduction
      end

      # For "activate only once each turn".
      def record_activation!
        ability.source.activated_this_turn!(ability.class) if ability.once_each_turn?
        ability.source.activated_ever!(ability.class) if ability.once_ever?
      end

      def countered!
        game.notify!(Events::AbilityCountered.new(ability: ability, player: player))
      end

      def pay_mana(payment)
        pay(:mana, payment)
        self
      end

      # "For each mana in this ability's activation cost, you may tap an untapped creature you control rather than
      # pay that mana" (Heirloom Epic): taps `creature` to pay {1} of the generic cost. Call it before paying mana.
      def convoke(creature)
        raise "#{ability.source.name}'s ability can't be paid by tapping creatures" unless ability.respond_to?(:convoke?) && ability.convoke?
        raise "#{creature.name} is tapped" if creature.tapped?
        raise "#{player.inspect} does not control #{creature.name}" unless creature.controller == player

        mana = costs.find { _1.is_a?(Costs::Mana) }
        raise "no generic mana left to pay with #{creature.name}" unless mana&.balance&.[](:generic).to_i.positive?

        mana.adjusted_by(generic: -1)
        creature.tap!
        self
      end

      def pay_self_tap
        pay(:self_tap)
      end

      def pay_tap(target)
        pay(:tap, target)
      end

      # What was tapped is passed to `resolve!(tapped:)` for abilities that care about it (Station counts its power).
      def pay_multi_tap(targets)
        pay(:multi_tap, targets)
        @tapped = Array(targets)
        self
      end

      # What was sacrificed is passed to `resolve!(sacrificed:)` for abilities that care about it (Demon of Fate's Design).
      def pay_sacrifice(targets)
        pay(:sacrifice, targets)
        @sacrificed = Array(targets)
      end

      def pay_return_lands(lands)
        pay(:return_lands, lands)
      end

      def pay_return_creature(creature)
        pay(:return_creature, creature)
      end

      def pay_self_sacrifice
        pay(:self_sacrifice)
      end

      def pay_self_exile
        pay(:self_exile)
      end

      def pay_self_discard
        pay(:self_discard)
      end

      def pay_discard(targets)
        pay(:discard, targets)
      end

      def pay_blight(creature)
        pay(:blight, creature)
      end

      # `payment`: three graveyard cards to exile, or a Food to sacrifice.
      def pay_forage(payment)
        pay(:forage, payment)
      end

      # The cards to exile from the graveyard ("Exile this card and two other cards named ..."), source included if it is one.
      def pay_exile_from_graveyard(cards)
        pay(:exile_from_graveyard, cards)
      end

      def perform
        record_activation!
        game.stack.add(self)

        game.notify!(Events::AbilityActivated.new(ability: ability, player: player, targets: targets))
        targets.grep(Permanent).uniq.each do |target|
          game.notify!(Events::BecameTarget.new(permanent: target, controller: player, source: ability.source))
        end
      end

      def pay(cost_type, payment = nil)
        cost_type = case cost_type
        when :mana
          Costs::Mana
        when :self_tap
          Costs::SelfTap
        when :tap
          Costs::Tap
        when :multi_tap
          Costs::MultiTap
        when :discard
          Costs::Discard
        when :blight
          Costs::Blight
        when :forage
          Costs::Forage
        when :sacrifice
          Costs::Sacrifice
        when :return_lands
          Costs::ReturnLands
        when :return_creature
          Costs::ReturnCreatureType
        when :self_sacrifice
          Costs::SelfSacrifice
        when :self_exile
          Costs::SelfExile
        when :self_discard
          Costs::SelfDiscard
        when :exile_from_graveyard
          Costs::ExileFromGraveyard
        else
          raise "unknown cost type: #{cost_type}"
        end

        cost = costs.find { |cost| cost.is_a?(cost_type) }
        raise "Unknown cost: #{cost_type}" if cost.nil?
        raise IllegalAction.new(self, cost.unpayable_reason) if cost.respond_to?(:unpayable_reason) && cost.unpayable_reason

        if cost.is_a?(Costs::Mana) && (any_color_for_creature_activations? || any_color_for_any_cost?)
          cost.treat_any_color_as_any!
        end

        pay_method = cost.method(:pay)
        args = {}
        args[:player] = player if pay_method.parameters.include?([:keyreq, :player])
        args[:payment] = payment if pay_method.parameters.include?([:keyreq, :payment])
        cost.pay(**args)

        self
      end

      def any_color_for_creature_activations?
        game.battlefield.static_abilities
          .of_type(Abilities::Static::AnyColorForCreatureActivations)
          .applies_to(ability.source)
          .any?
      end

      def any_color_for_any_cost?
        game.battlefield.static_abilities
          .of_type(Abilities::Static::AnyColorForAnyCost)
          .any? { |ability| ability.controller == player }
      end

      def has_cost?(cost_type)
        costs.any? { |cost| cost.is_a?(cost_type) }
      end

      def finalize_costs!(player)
        costs.each { |cost| cost.finalize!(player) }
      end

      def resolve!
        resolve_with_args(ability, target: targets.first, targets: targets, sacrificed: sacrificed, tapped: tapped)
      end
    end
  end
end
