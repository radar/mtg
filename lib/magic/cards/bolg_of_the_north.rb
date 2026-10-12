module Magic
  module Cards
    BolgOfTheNorth = Creature("Bolg of the North") do
      cost generic: 3, black: 1, red: 1
      legendary_creature_type("Goblin Soldier")
      power 5
      toughness 5
    end

    class BolgOfTheNorth < Creature
      # The reflexive trigger: "When you do, Bolg deals damage equal to that creature's power to another target
      # creature. If excess damage was dealt this way, amass Goblins X, where X is that excess damage."
      class DamageChoice < Magic::Choice::Targeted
        attr_reader :damage

        def initialize(actor:, damage:)
          @damage = damage
          super(actor: actor)
        end

        def prompt = "Deal #{damage} damage to another target creature."

        def choices
          battlefield.creatures.reject { _1 == actor }
        end

        def choice_amount = 1

        def resolve!(target:)
          lethal = [target.toughness - target.damage, 0].max
          excess = [damage - lethal, 0].max
          trigger_effect(:deal_damage, target: target, damage: damage)
          Amass.call(source: actor, controller: controller, amount: excess) if excess.positive?
        end
      end

      # "When Bolg enters, you may sacrifice another creature."
      class SacrificeChoice < Magic::Choice::SacrificePermanent
        def prompt = "Sacrifice another creature?"

        def resolve!(sacrifice: nil)
          sacrifice ||= candidates.first
          damage = [sacrifice.power, 0].max
          super(sacrifice: sacrifice)
          choice = DamageChoice.new(actor: actor, damage: damage)
          game.add_choice(choice) if damage.positive? && choice.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = SacrificeChoice.new(actor: actor, type: "Creature", other: true)
          game.add_choice(choice) if choice.candidates.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
