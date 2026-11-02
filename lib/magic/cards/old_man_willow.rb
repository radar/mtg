module Magic
  module Cards
    OldManWillow = Creature("Old Man Willow") do
      cost "{2}{B}{G}"
      legendary_creature_type "Treefolk"
      power 0
      toughness 0
    end

    class OldManWillow < Creature
      # "Old Man Willow's power and toughness are each equal to the number of lands you control."
      class LandCount < Abilities::Static::CharacteristicSetting
        def applicable_targets = [source]

        def set_base_power = controller.lands.count

        def set_base_toughness = controller.lands.count
      end

      def static_abilities = [LandCount]

      # "When you do, target creature an opponent controls gets -2/-2 until end of turn."
      class ShrinkChoice < Magic::Choice::Targeted
        def choices = battlefield.not_controlled_by(controller).creatures

        def choice_amount = 1

        def resolve!(target:)
          pump(target, -2, -2)
        end

        # The reflexive target is mandatory (CR 603.3d): declining picks a legal creature.
        def decline!
          target = choices.first
          resolve!(target: target) if target
        end
      end

      # "...you may sacrifice another creature or a token."
      class SacrificeChoice < Magic::Choice::SacrificePermanent
        def candidates
          controller.permanents.select { _1 != actor && (_1.creature? || _1.token?) }
        end

        def resolve!(sacrifice: nil)
          super
          shrink = ShrinkChoice.new(actor: actor)
          game.add_choice(shrink) if shrink.choices.any?
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attack.attacker == actor
        end

        def call
          choice = SacrificeChoice.new(actor: actor)
          game.add_choice(choice) if choice.candidates.any?
        end
      end

      def event_handlers = { Events::AttackDeclared => AttacksTrigger }
    end
  end
end
