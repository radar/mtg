module Magic
  module Cards
    SkoaEmbermage = Creature("Skoa, Embermage") do
      cost "{4}{R}{R}"
      legendary_creature_type "Goblin Wizard"
      power 4
      toughness 4
    end

    class SkoaEmbermage < Creature
      # "When Skoa enters, it deals 4 damage to any target."
      class DamageChoice < Magic::Choice::Targeted
        def prompt = "Choose a target for Skoa to deal 4 damage to."
        def choices = game.any_target
        def choice_amount = 1

        def resolve!(target:)
          deal_damage(4, to: target)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(DamageChoice.new(actor: actor))
        end
      end

      # "Sacrifice two Mountains": paid with `pay_sacrifice([mountain, mountain])`.
      class SacrificeTwoMountains < Costs::Sacrifice
        def can_pay?(_player = nil) = choices.size >= 2

        def pay(payment:)
          payment = Array(payment)
          unless payment.uniq.size == 2 && payment.all? { choices.include?(_1) }
            raise "Sacrifice exactly two of: #{choices.map(&:name).join(', ')}"
          end

          payment.each(&:sacrifice!)
        end
      end

      # "Grandeur -- Discard another card named Skoa, Embermage, Sacrifice two Mountains: Skoa deals 4 damage to any
      # target." Activated from hand; pay with `pay_discard(other_skoa)` and `pay_sacrifice([mountain, mountain])`.
      class GrandeurAbility < Magic::ActivatedAbility
        def description = "Grandeur: Skoa deals 4 damage to any target"

        def costs
          player = source.owner
          [
            Costs::Discard.new(player, ->(card) { card != source && card.name == "Skoa, Embermage" }),
            SacrificeTwoMountains.new(source, player.lands.select { _1.type?("Mountain") })
          ]
        end

        def requirements_met?
          !!source.zone&.hand? && source.owner == controller
        end

        def target_choices = game.any_target

        def resolve!(target:)
          deal_damage(4, to: target)
        end
      end

      def etb_triggers = [EntersTrigger]
      def hand_abilities = [GrandeurAbility.new(source: self)]
    end
  end
end
