module Magic
  module Cards
    PursuedWhale = Creature("Pursued Whale") do
      cost generic: 5, blue: 2
      creature_type "Whale"
      power 8
      toughness 8
    end

    class PursuedWhale < Creature
      class PirateToken < Token
        token_name "Pirate"
        creature_type "Pirate"
        colors :red
        power 1
        toughness 1

        # "This token can't block."
        def can_block?(_) = false

        # "Creatures you control attack each combat if able."
        class AttackEachCombat < Abilities::Static::MustAttack
          def applies_to?(permanent) = permanent.controller == @source.controller
        end

        def static_abilities = [AttackEachCombat]
      end

      # "When this creature enters, each opponent creates a 1/1 red Pirate creature token with 'This token can't
      # block' and 'Creatures you control attack each combat if able.'"
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each { |opponent| trigger_effect(:create_token, token_class: PirateToken, controller: opponent) }
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Spells your opponents cast that target this creature cost {3} more to cast." Known once the targets are chosen:
      # see `Actions::Cast#apply_target_cost_increases!`.
      class TargetingTax < StaticAbility
        def cost_increase_for_targeting(_card, targets, player)
          targets.include?(@source) && player != @source.controller ? 3 : 0
        end
      end

      def static_abilities = [TargetingTax]
    end
  end
end
