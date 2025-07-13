module PinFlags
  class FeatureTagsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

    before_action :set_filter_param, only: %i[index show create]
    before_action :set_enabled_param, only: %i[index show create]
    before_action :set_subscriptions_param, only: %i[index create]
    before_action :set_current_page, only: %i[index show create]
    before_action :set_feature_taggable_type, only: %i[show]
    before_action :set_feature_tag, only: %i[show update destroy]

    PER_PAGE ||= 10

    def index
      @paginator = PinFlags::Page.new(fetch_feature_tags, page: @current_page, page_size: PER_PAGE)
      @feature_tags = @paginator.records

      # Handle overflow (when page number is too high)
      if @paginator.index > @paginator.pages_count && @paginator.pages_count&.positive?
        redirect_to feature_tags_path(search: @filter_param, enabled: @enabled_param, subscriptions: @subscriptions_param)
      end
    end

    def show
      @paginator = PinFlags::Page.new(fetch_feature_subscriptions, page: @current_page, page_size: PER_PAGE)
      @feature_subscriptions = @paginator.records

      # Handle overflow for feature subscriptions
      if @paginator.index > @paginator.pages_count && @paginator.pages_count&.positive?
        redirect_to feature_tag_path(@feature_tag, feature_taggable_type: @feature_taggable_type, filter: @filter_param)
      end
    end

    def new
      @feature_tag = PinFlags::FeatureTag.new
    end

    def create
      @feature_tag = PinFlags::FeatureTag.new(feature_tag_params)

      if @feature_tag.save
        @feature_tags = fetch_feature_tags
        @paginator = PinFlags::Page.new(@feature_tags, page: @current_page, page_size: PER_PAGE)
        @feature_tags = @paginator.records
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

    def set_current_page
      @current_page = params.fetch(:page, 1).to_i
    end

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

    def set_subscriptions_param
      @subscriptions_param = params.fetch(:subscriptions, nil)
    end

    def set_feature_taggable_type
      @feature_taggable_type = params.fetch(:feature_taggable_type, nil)
    end

    def fetch_feature_tags
      scope = FeatureTag.all.includes(:feature_subscriptions).order(created_at: :desc)
      scope = scope.with_name_like(@filter_param) if @filter_param.present?
      scope = filter_by_enabled_status(scope) if @enabled_param.present?
      scope = filter_by_subscriptions_status(scope) if @subscriptions_param.present?
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

    def filter_by_subscriptions_status(scope)
      has_subscriptions = ActiveModel::Type::Boolean.new.cast(@subscriptions_param)
      has_subscriptions ? scope.joins(:feature_subscriptions).distinct : scope.left_joins(:feature_subscriptions).where(feature_subscriptions: { id: nil })
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
