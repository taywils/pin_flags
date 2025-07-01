module PinFlags
  class FeatureTagsController < ApplicationController
    before_action :set_search_param, only: %i[index show]

    def index
      @feature_tags = PinFlags::FeatureTag.all
    end

    def show
    end

    def new
      @feature_tag = PinFlags::FeatureTag.new
    end

    def create
      @feature_tag = PinFlags::FeatureTag.new(feature_tag_params)

      if @feature_tag.save
        redirect_to pin_flags.feature_tags_path, notice: "Feature tag created successfully."
      else
        flash.now[:alert] = @feature_tag.errors.full_messages.to_sentence
        render :new
      end
    end

    def update
    end

    def destroy
    end

    private

    def feature_tag_params
      params.expect(feature_tag: [ :name, :enabled ])
    end

    def set_search_param
      @search_param = params.fetch(:filter, nil)
    end
  end
end
