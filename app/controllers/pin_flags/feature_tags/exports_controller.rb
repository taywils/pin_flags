module PinFlags
  module FeatureTags
    class ExportsController < ApplicationController
      def index
        respond_to do |format|
          format.json { send_data(PinFlags::FeatureTag.export_as_json, filename: export_filename) }
        end
      end

      private

      def export_filename
        timestamp = Time.zone.now.strftime("%Y%m%d%H%M%S")
        "pin_flags_feature_tags_#{timestamp}.json"
      end
    end
  end
end
