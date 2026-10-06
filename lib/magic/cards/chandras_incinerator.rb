module Magic
  module Cards
    ChandrasIncinerator = Creature("Chandra's Incinerator") do
      cost generic: 5, red: 1
      creature_type "Elemental"
      keywords :trample
      power 6
      toughness 6
    end

    class ChandrasIncinerator < Creature
      # "This spell costs {X} less to cast, where X is the total amount of noncombat damage dealt to your opponents
      # this turn."
      def self_mana_cost_adjustment
        { generic: -> { -noncombat_damage_to_opponents_this_turn } }
      end

      def noncombat_damage_to_opponents_this_turn
        player = controller || owner
        game.current_turn.events.sum do |event|
          event.is_a?(Events::DamageDealt) && !event.combat? && event.target.is_a?(Magic::Player) && event.target != player ? event.damage : 0
        end
      end

      # "...this creature deals that much damage to target creature or planeswalker that player controls."
      class DamageChoice < Magic::Choice::Targeted
        attr_reader :damage, :player

        def initialize(actor:, damage:, player:)
          super(actor:)
          @damage = damage
          @player = player
        end

        def choices = battlefield.by_any_type(T::Creature, T::Planeswalker).controlled_by(player)
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage:)
        end
      end

      # "Whenever a source you control deals noncombat damage to an opponent, ..."
      class DamageTrigger < TriggeredAbility::NoncombatDamageToOpponent
        def call
          choice = DamageChoice.new(actor:, damage: event.damage, player: event.target)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::DamageDealt => DamageTrigger }
    end
  end
end
