module PinFlags
  module FeatureTags
    class ImportsController < ApplicationController
      MAX_FILE_SIZE ||= 2.megabytes

      def create
        if valid_json_file? && import_successful?
          respond_with_success
        else
          respond_with_error
        end
      end

      private

      def import_params
        params.permit(:json_file, :authenticity_token, :commit)
      end

      def valid_json_file?
        return false if import_params[:json_file].blank?

        file = import_params[:json_file]
        correct_type = file.content_type == "application/json"
        correct_size = file.size <= MAX_FILE_SIZE

        correct_type && correct_size
      end

      def import_successful?
        file_contents = import_params[:json_file].read
        PinFlags::FeatureTag.import_from_json(file_contents)
      rescue PinFlags::FeatureTagImportError => e
        Rails.logger.error(e.message)
        false
      end

      def respond_with_success
        respond_to do |format|
          format.html { redirect_to feature_tags_path, notice: "Feature tags were successfully imported." }
        end
      end

      def error_message
        if import_params[:json_file].blank?
          "No file uploaded."
        elsif import_params[:json_file].content_type != "application/json"
          "File must be JSON format."
        elsif import_params[:json_file].size > MAX_FILE_SIZE
          "File size must be less than #{MAX_FILE_SIZE / 1.megabyte}MB."
        else
          "Invalid JSON file or import failed."
        end
      end

      def respond_with_error
        message = error_message

        respond_to do |format|
          format.html { redirect_to feature_tags_path, alert: message }
        end
      end
    end
  end
end
