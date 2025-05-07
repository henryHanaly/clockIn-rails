class UsersController < ApplicationController
    def user_profile
        render json: { name: @current_user.name,  email: @current_user.email }
    end
end
