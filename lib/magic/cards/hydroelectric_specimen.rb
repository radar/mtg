module Magic
  module Cards
    # The land back face of Hydroelectric Specimen. It has no mana cost.
    HydroelectricLaboratory = Card("Hydroelectric Laboratory") do
      type "Land"
    end

    class HydroelectricLaboratory < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :blue
      end

      def activated_abilities = [ManaAbility]
    end

    HydroelectricSpecimen = Creature("Hydroelectric Specimen") do
      cost generic: 2, blue: 1
      creature_type "Weird"
      power 1
      toughness 4
      keywords :flash
      back_face HydroelectricLaboratory
    end

    class HydroelectricSpecimen < Creature
      # "When this creature enters, you may change the target of target instant or sorcery spell with a single
      # target to this creature." The new target must be legal for the spell.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class RetargetChoice < Magic::Choice::Targeted
          def choices
            game.stack.spells.select do |spell|
              (spell.card.instant? || spell.card.sorcery?) && spell.targets.size == 1 && spell.can_target?(actor)
            end
          end

          def choice_amount = 0..1

          def resolve!(target:)
            target.targeting(actor)
          end
        end

        def call
          choice = RetargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
