module Magic
  module Cards
    OrcristGoblinCleaver = Equipment("Orcrist, Goblin-cleaver") do
      legendary_artifact
      cost generic: 3
      equip [Costs::Mana.new(generic: 3)]
    end

    class OrcristGoblinCleaver < Equipment
      # "Equipped creature gets +2/+2 and has trample."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      class GrantTrample < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE
        applies_to_target
      end

      # "choose a creature type. Create a Treasure token for each creature you control of that type."
      # Answer with `game.resolve_choice!(creature_type: "Dwarf")`.
      class ChooseTypeChoice < Magic::Choice::CreatureType
        def prompt = "Choose a creature type"

        def choices = Magic::Types::Creatures.values

        def resolve!(creature_type:)
          amount = controller.creatures.count { _1.type?(creature_type) }
          trigger_effect(:create_token, token_class: Tokens::Treasure, controller: controller, amount: amount) if amount.positive?
        end
      end

      # "Whenever equipped creature deals combat damage to a player, ..."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          actor.attached_to && event.source == actor.attached_to && event.target.player?
        end

        def call
          game.add_choice(ChooseTypeChoice.new(actor: actor))
        end
      end

      def static_abilities = [Buff, GrantTrample]

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
