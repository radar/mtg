# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Whenever ~ transforms into ~ and at the beginning of your first main phase, add two mana of
      # any one color. Spend this mana only to cast spells with mana value 4 or greater." -- two
      # triggers with one effect (`merge` splits it), each asking for the colour.
      class RestrictedManaTrigger < Data.define(:amount, :minimum, :moment)
        include Rule

        LINE = /\AWhenever ~ transforms into ~ and at the beginning of your first main phase, add (?<amount>\w+) mana of any one color\. Spend this mana only to cast spells with mana value (?<minimum>\d+) or greater\.?\z/i

        def self.parse(line)
          new(amount: Number.parse($~[:amount]), minimum: $~[:minimum].to_i, moment: :both) if LINE.match(line)
        end

        def self.merge(rules)
          rules.flat_map { |rule| %i[transformed first_main].map { |moment| rule.with(moment:) } }
        end

        def kinds = %i[creature]
        def hook = :event_handlers
        def class_base_name = transformed? ? "TransformedManaTrigger" : "FirstMainManaTrigger"
        def handled_event = transformed? ? "Events::PermanentTransformed" : "Events::FirstMainPhase"

        def class_source(name)
          condition = transformed? ? "event.permanent == actor" : "event.active_player == controller"
          <<~RUBY
            class #{name} < TriggeredAbility
              class ColorChoice < Magic::Choice::Color
                def resolve!(color:)
                  controller.add_mana({ color => #{amount} }, restriction: ManaRestriction::MinimumManaValue.new(#{minimum}))
                end
              end

              def should_perform?
                #{condition}
              end

              def call
                game.choices.add(ColorChoice.new(actor: actor))
              end
            end
          RUBY
        end

        private

        def transformed? = moment == :transformed
      end
    end
  end
end
