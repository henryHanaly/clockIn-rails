class UsersController < ApplicationController
    def user_profile
        render json: { name: @current_user.name,  email: @current_user.email }, status: :ok
    end

    def all_user
        user_all = User.select(:id, :name).where.not(id: @current_user.id).where.not(id: Follow.select(:follower_id)).page(params[:page]).per(params[:per_page])
        render json: {
          data: user_all,
          message: "success",
          meta: meta_pagination(user_all)
        }, status: :ok
    end

    def follow
        user_to_follow = User.find_by(id: params[:user_id])
        if user_to_follow.nil?
          render json: { error: "User not found" }, status: :not_found
        elsif user_to_follow == @current_user
          render json: { error: "You cannot follow yourself" }, status: :unprocessable_entity
        else
          follow =  Follow.new(follower: @current_user, followed: user_to_follow)
          if follow.save
            render json: {
              data: {},
              message: "Now following #{user_to_follow.name}",
              meta: {}
              }, status: :ok
          else
            render json: { error:  @follow.errors }, status: :unprocessable_entity
          end
        end

      rescue StandardError => e
        render json: { error:  e }, status: :unprocessable_entity
    end


    def unfollow
      user_to_unfollow = User.find_by(id: params[:user_id])
        if user_to_unfollow.nil?
          render json: { error: "User not found" }, status: :not_found
        elsif user_to_unfollow == @current_user
          render json: { error: "You cannot unfollow yourself" }, status: :unprocessable_entity
        else
          follow = Follow.find_by(follower: @current_user, followed: user_to_unfollow)
          if follow
            follow.destroy
            render json: {
              data: {},
              message: "Unfollowed #{user_to_unfollow.name}",
              meta: {}
              }, status: :ok
          else
            render json: { error: "You are not following #{user_to_unfollow.name}" }, status: :unprocessable_entity
          end
        end
    end

    def friends
      following_ids = @current_user.following.pluck(:id)
      one_week_ago = Time.current - 7.days
      records = SleepRecord.select(:clock_in, :clock_out, :duration, :name)
                           .joins(:user)
                           .where(user_id: following_ids)
                           .where("clock_in >= ?", one_week_ago)
                           .where.not(clock_out: nil)
                           .order(duration: :desc)


      if records.empty?
        render json: {
          data: {},
          message: "No friend sleep records found",
          meta: {}
          }, status: :ok and return
      end

    # Build new response
    new_response = records.each_with_index.to_h do |record, index|
        [ "record #{index + 1}", "from user #{record.name}  clock-in #{record.clock_in} - clock-out #{record.clock_out} - duration #{record.duration}" ]
    end
      render json: {
        data: new_response,
        message: "success",
        meta: {}
      }, status: :ok
    end
end
