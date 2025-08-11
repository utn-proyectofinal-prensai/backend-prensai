# frozen_string_literal: true

module API
  module V1
    class UsersController < API::V1::APIController
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        @users = policy_scope(User)
        render :index
      end

      def show
        authorize @user
      end

      def create
        authorize User, :create?
        @user = User.new(create_user_params)
        @user.save!
        render :show, status: :created
      end

      def update
        authorize @user
        @user.update!(update_user_params)
        render :show
      end

      def destroy
        authorize @user
        @user.destroy!
        head :no_content
      end

      private

      def set_user
        @user = params[:id].present? ? User.find(params[:id]) : current_user
      end

      def create_user_params
        params.require(:user).permit(permitted_attributes(User))
      end

      def update_user_params
        params.require(:user).permit(permitted_attributes(@user))
      end
    end
  end
end
