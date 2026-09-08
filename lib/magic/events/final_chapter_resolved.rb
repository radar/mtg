module Magic
  module Events
    class FinalChapterResolved
      attr_reader :saga

      def initialize(saga:)
        @saga = saga
      end
    end
  end
end