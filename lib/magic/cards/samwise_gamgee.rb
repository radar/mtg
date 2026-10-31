module Magic
  module Cards
    SamwiseGamgee = Creature("Samwise Gamgee") do
      cost green: 1, white: 1
      legendary_creature_type "Halfling Peasant"
      power 2
      toughness 2
    end

    class SamwiseGamgee < Creature
      # "Whenever another nontoken creature you control enters, create a Food token."
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          permanent = event.permanent
          permanent != actor && permanent.creature? && !permanent.token? && under_your_control?
        end

        def call
          create_token(token: Tokens::Food)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }

      # "Sacrifice three Foods"
      class SacrificeThreeFoods < Costs::Sacrifice
        def can_pay?(_player = nil) = choices.size >= 3

        def pay(payment:)
          payment = Array(payment)
          unless payment.uniq.size == 3 && payment.all? { choices.include?(_1) }
            raise "Sacrifice exactly three of: #{choices.map(&:name).join(', ')}"
          end

          payment.each(&:sacrifice!)
        end
      end

      # "Sacrifice three Foods: Return target historic card from your graveyard to your hand." Artifacts, legendaries and
      # Sagas are historic.
      class ReturnAbility < Magic::ActivatedAbility
        def costs
          [SacrificeThreeFoods.new(source, source.controller.permanents.select { _1.type?("Food") })]
        end

        def target_choices
          source.controller.graveyard.cards.select { _1.artifact? || _1.legendary? || _1.type?("Saga") }
        end

        def resolve!(target:)
          move_card(target, to: source.controller.hand)
        end
      end

      def activated_abilities = [ReturnAbility]
    end
  end
end
