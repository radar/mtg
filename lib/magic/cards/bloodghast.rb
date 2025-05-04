module Magic
  module Cards
    Bloodghast = Creature("Bloodghast") do
      cost "{B}{B}"
      creature_type "Vampire Spirit"
      power 2
      toughness 1
    end

    class Bloodghast < Creature
      class HasteGrant < Abilities::Static::KeywordGrant
        def keyword_grants
          [Keywords::HASTE]
        end

        def applicable_targets
          if source.opponents.any? { _1.life <= 10 }
            [source]
          else
            []
          end
        end
      end

      class Choice < Magic::Choice::May
        def resolve!(target:)
          target.resolve!
        end
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          actor.zone.graveyard?
        end

        def call
          game.add_choice(Bloodghast::Choice.new(actor: actor))
        end
      end

      def can_block?(_)
        false
      end

      def static_abilities
        [HasteGrant]
      end

      def event_handlers
        {
          Events::Landfall => LandfallTrigger
        }
      end
    end
  end
end
