# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "{2}{R}, {T}: ~ deals 1 damage to any target." / "{1}, Sacrifice ~: Draw a
      # card. Activate only as a sorcery." / "... Activate only once each turn."
      # Costs are any Costs::Parser understands; the effects are anything EffectList
      # parses, rendered like a spell's.
      #
      # "Activate only if <condition>." (a `Condition`, e.g. "you control five or more lands") becomes
      # `requirements_met?`.
      #
      # "Activate only once." (ever, per permanent) becomes `activate_only_once`.
      class ActivatedAbility < Data.define(:costs, :effect_list, :sorcery_speed, :once_each_turn, :only_if, :once_ever)
        include Rule

        # "Remove a counter from ~" (no type named) means -1/-1: the only cards that
        # phrase it this way ("enters with N -1/-1 counters on it", then this ability)
        # have no other counter type to be ambiguous with.
        COST = /(?:\{(?:\d+|[WUBRGC]|[WUBRG]\/[WUBRG]|\d+\/[WUBRG])\})+|\{T\}|Sacrifice ~|Sacrifice a creature|Exile ~|Discard a card|Blight \d+|Remove (?:\d+|\w+) (?:[\w+\/-]+ )?counters? from ~(?: and sacrifice it)?/
        LINE = /\A(?<costs>#{COST}(?:, #{COST})*): (?<effects>.+?)(?<sorcery> Activate only as a sorcery\.)?(?<once> Activate only once each turn\.)?(?<ever> Activate only once\.)?(?: Activate only if (?<only_if>[^.]+)\.)?\z/
        # "~ becomes a Werewolf. Put two +1/+1 counters on it and ...": "it" is ~, since nothing was targeted.
        BECOMES_THEN_IT = /\A(?<becomes>~ becomes an? [A-Z][\w-]*\. )(?<rest>.*)\z/

        def self.parse(line)
          return unless (m = LINE.match(line))

          only_if = Condition.parse(m[:only_if]) if m[:only_if]
          return if m[:only_if] && !only_if

          effects = m[:effects]
          if (becomes = BECOMES_THEN_IT.match(effects)) && !effects.include?("target")
            effects = becomes[:becomes] + becomes[:rest].gsub(/\bon it\b/, "on ~")
          end
          effect_list = EffectList.parse(effects) or return
          m[:costs].scan(/Remove \w+ (?:([\w+\/-]+) )?counters? from/) { Magic::Counters[($1 || "-1/-1").downcase] } # raises for an unknown counter type
          new(costs: costs(m[:costs]), effect_list:, sorcery_speed: !m[:sorcery].nil?, once_each_turn: !m[:once].nil?, only_if:, once_ever: !m[:ever].nil?)
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        # "Remove three quest counters from ~ and sacrifice it" is two costs.
        def self.costs(text)
          text.gsub(" and sacrifice it", ", Sacrifice ~")
              .gsub(/Remove (\w+) (?:([\w+\/-]+) )?counters? from/) { "Remove #{Number.parse($1)} #{$2 || '-1/-1'} counters from" }
              .gsub("~", "{this}")
        end

        def initialize(costs:, effect_list:, sorcery_speed:, once_each_turn: false, only_if: nil, once_ever: false) = super

        def kinds = PERMANENT_KINDS
        def hook = :activated_abilities
        def class_base_name = "ActivatedAbility"

        def class_source(name)
          body = ["costs #{costs.inspect}\n"]
          body << "once_each_turn\n" if once_each_turn
          body << "activate_only_once\n" if once_ever
          body << "activate_only_as_sorcery\n" if sorcery_speed
          body << "def requirements_met?\n  #{only_if}\nend\n" if only_if
          body << effect_list.spell_source(this: "source")
          "class #{name} < Magic::ActivatedAbility\n#{body.join("\n").gsub(/^(?=.)/, '  ')}end\n"
        end
      end
    end
  end
end
