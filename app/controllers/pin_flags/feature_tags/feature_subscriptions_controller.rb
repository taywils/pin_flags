module PinFlags
  module FeatureTags
    class FeatureSubscriptionsController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      before_action :set_feature_tag
      before_action :set_current_page, only: %i[create destroy]
      before_action :set_filter_param, only: %i[create destroy]
      before_action :set_feature_taggable_type, only: %i[create destroy]
      before_action :set_feature_subscription, only: %i[destroy]

      def new
        @feature_subscription = @feature_tag.feature_subscriptions.new
      end

      def create
        if feature_subscription_params[:bulk_upload] == "1"
          # TODO: Move this logic into a ActiveModel PORO for better separation of concerns
          # TODO: Change the logic to use upsert_all or similar for performance
          create_feature_subscriptions_in_bulk
        else
          create_single_feature_subscription
        end
      end

      def destroy
        @feature_subscription.destroy

        respond_to do |format|
          format.html { redirect_to @feature_tag, notice: "Feature Subscription was successfully destroyed." }
          format.turbo_stream
        end
      end

      private

      def set_feature_tag
        @feature_tag = PinFlags::FeatureTag.find_by(id: params[:feature_tag_id])
        raise ActiveRecord::RecordNotFound if @feature_tag.blank?
      end

      def set_current_page
        @current_page = params.fetch(:page, 1).to_i
      end

      def set_filter_param
        @filter_param = params.fetch(:filter, nil)
      end

      def set_feature_taggable_type
        @feature_taggable_type = params.fetch(:feature_taggable_type, nil)
      end

      def feature_subscription_params
        params.expect(feature_subscription: [ :feature_taggable_type, :feature_taggable_id, :bulk_upload ])
      end

      def set_feature_subscription
        @feature_subscription = @feature_tag.feature_subscriptions.find_by(id: params[:id])
        raise ActiveRecord::RecordNotFound if @feature_subscription.blank?
      end

      def record_not_found
        alert_message = @feature_tag.blank? ? "Feature Tag not found." : "Feature Subscription not found."
        redirect_to pin_flags.feature_tags_path, alert: alert_message
      end

      def create_single_feature_subscription
        @feature_subscription = @feature_tag.feature_subscriptions.new(feature_subscription_params.except(:bulk_upload))

        if @feature_subscription.save
          filtered_subscriptions = fetch_filtered_feature_subscriptions
          @paginator = PinFlags::Page.new(filtered_subscriptions, page: @current_page, page_size: PinFlags::FeatureTagsController::PER_PAGE)
          @feature_subscriptions = @paginator.records

          respond_to do |format|
            format.html { redirect_to pin_flags.feature_tag_path(@feature_tag, filter: @filter_param, feature_taggable_type: @feature_taggable_type), notice: "Feature Subscription was successfully created." }
            format.turbo_stream
          end
        else
          render :new, status: :unprocessable_content
        end
      end

      def create_feature_subscriptions_in_bulk
        feature_taggable_ids = feature_subscription_params[:feature_taggable_id].split(",").map(&:strip)

        if process_bulk_transaction(feature_taggable_ids)
          handle_feature_subscriptions_in_bulk_success
        else
          handle_feature_subscriptions_in_bulk_failure
        end
      end

      def process_bulk_transaction(feature_taggable_ids)
        ActiveRecord::Base.transaction do
          process_feature_taggable_ids(feature_taggable_ids)
        rescue ActiveRecord::Rollback
          return false
        end
        true
      end

      def process_feature_taggable_ids(feature_taggable_ids)
        feature_taggable_ids.each do |feature_taggable_id|
          @feature_tag.feature_subscriptions.find_or_create_by!(
            feature_taggable_type: feature_subscription_params[:feature_taggable_type],
            feature_taggable_id: feature_taggable_id
          )
        rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => _e
          raise ActiveRecord::Rollback
        end
      end

      def handle_feature_subscriptions_in_bulk_success
        respond_to do |format|
          format.html do
            redirect_to pin_flags.feature_tag_path(@feature_tag, filter: @filter_param, feature_taggable_type: @feature_taggable_type), notice: "Feature Subscriptions were successfully created."
          end
          format.turbo_stream
        end
      end

      def handle_feature_subscriptions_in_bulk_failure
        alert_message = "One or more Feature Taggable IDs are invalid."
        flash.now[:alert] = alert_message
        @feature_subscription = @feature_tag.feature_subscriptions.new(
          feature_taggable_type: feature_subscription_params[:feature_taggable_type],
          feature_taggable_id: feature_subscription_params[:feature_taggable_id]
        )
        @feature_subscription.errors.add(:feature_taggable_id, alert_message)
        render :new, status: :unprocessable_content
      end

      def fetch_filtered_feature_subscriptions
        feature_subscriptions = @feature_tag.feature_subscriptions.order(created_at: :desc)

        if @feature_taggable_type.present?
          feature_subscriptions = feature_subscriptions.where(feature_taggable_type: @feature_taggable_type)
        end

        if @filter_param.present?
          feature_subscriptions = feature_subscriptions.where(feature_taggable_id: @filter_param.strip)
        end

        feature_subscriptions
      end
    end
  end
end
