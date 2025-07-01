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
    end

    def update
    end

    def destroy
    end

    private

    def set_search_param
      @search_param = params.fetch(:filter, nil)
    end
  end
end
