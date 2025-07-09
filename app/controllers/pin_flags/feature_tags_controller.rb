module PinFlags
  class FeatureTagsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

    before_action :set_filter_param, only: %i[index show]
    before_action :set_enabled_param, only: %i[index show]
    before_action :set_feature_taggable_type, only: %i[show]
    before_action :set_feature_tag, only: %i[show update destroy]

    PER_PAGE ||= 10

    # TODO: Add pagination support
    def index
      @feature_tags = fetch_feature_tags
    end

    # TODO: Add pagination support
    def show
      @feature_subscriptions = fetch_feature_subscriptions
    end

    def new
      @feature_tag = PinFlags::FeatureTag.new
    end

    def create
      @feature_tag = PinFlags::FeatureTag.new(feature_tag_params)

      if @feature_tag.save
        @feature_tags = fetch_feature_tags
        handle_success(:create)
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @feature_tag.update(feature_tag_params)
        handle_success(:update)
      else
        render :index, status: :unprocessable_content
      end
    end

    def destroy
      @feature_tag.destroy
      handle_success(:delete)
    end

    private

    def set_feature_tag
      @feature_tag = PinFlags::FeatureTag.find(params[:id])
    end

    def feature_tag_params
      params.expect(feature_tag: [ :name, :enabled ])
    end

    def set_filter_param
      @filter_param = params.fetch(:filter, nil)
    end

    def set_enabled_param
      @enabled_param = params.fetch(:enabled, nil)
    end

    def set_feature_taggable_type
      @feature_taggable_type = params.fetch(:feature_taggable_type, nil)
    end

    def fetch_feature_tags
      scope = FeatureTag.all.includes(:feature_subscriptions).order(created_at: :desc)
      scope = scope.with_name_like(@filter_param) if @filter_param.present?
      scope = filter_by_enabled_status(scope) if @enabled_param.present?
      scope
    end

    def fetch_feature_subscriptions
      feature_subscriptions = @feature_tag.feature_subscriptions.order(created_at: :desc)

      if @feature_taggable_type.present?
        feature_subscriptions = feature_subscriptions.where(feature_taggable_type: @feature_taggable_type)
      end

      if @filter_param.present?
        feature_subscriptions = feature_subscriptions.where(feature_taggable_id: @filter_param.strip)
      end

      feature_subscriptions
    end


    def filter_by_enabled_status(scope)
      enabled = ActiveModel::Type::Boolean.new.cast(@enabled_param)
      enabled ? scope.enabled : scope.disabled
    end

    def handle_success(action)
      flash_notice = "Feature tag was successfully #{action}d."

      respond_to do |format|
        format.html { redirect_to feature_tags_path, notice: flash_notice }
        format.turbo_stream { flash.now[:notice] = flash_notice }
      end
    end

    def handle_record_not_found
      flash[:error] = "Feature tag not found."
      redirect_to pin_flags.feature_tags_path, status: :see_other
    end
  end
end
