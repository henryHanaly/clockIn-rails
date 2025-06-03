class UsersController < ApplicationController
    def user_profile
        render_success(data: @current_user, status: :ok)
    end

    def all_user
        user_all = User.select(:id, :name).where.not(id: @current_user.id).where.not(id: Follow.select(:follower_id)).page(params[:page]).per(params[:per_page])
        render_success(message: "success", data: user_all, meta: meta_pagination(user_all), status: :ok)
    end

    def follow
        user_to_follow = User.find_by(id: params[:user_id])
        if user_to_follow.nil?
          render_error(message: "User not found")
        elsif user_to_follow == @current_user
          render_error(message: "You cannot follow yourself")
        else
          follow =  Follow.new(follower: @current_user, followed: user_to_follow)
          if follow.save
            render_success(message: "Now following #{user_to_follow.name}")
          else
            render_error(message:  @follow.errors)
          end
        end

      rescue StandardError => e
        render_error(message: e)
    end


    def unfollow
      user_to_unfollow = User.find_by(id: params[:user_id])
        if user_to_unfollow.nil?
          render_error(message: "User not found")
        elsif user_to_unfollow == @current_user
          render_error(message: "You cannot unfollow yourself")
        else
          follow = Follow.find_by(follower: @current_user, followed: user_to_unfollow)
          if follow
            follow.destroy
              render_success(message: "Unfollowed #{user_to_unfollow.name}", status: :ok)
          else
            render_error(message: "You are not following #{user_to_unfollow.name}")
          end
        end
    end

    def friends
      # get data from redis first
      cache_key = "user:#{@current_user.id}:following_sleep_records"
      cached_data = $redis.get(cache_key)

      if cached_data
        render_success(data: JSON.parse(cached_data)) and return
      end

      following_ids = @current_user.following.pluck(:id)
      one_week_ago = Time.current - 7.days
      records = SleepRecord.select(:clock_in, :clock_out, :duration, :name)
                           .joins(:user)
                           .where(user_id: following_ids)
                           .where("clock_in >= ?", one_week_ago)
                           .where.not(clock_out: nil)
                           .order(duration: :desc)


      if records.empty?
        render_success(message: "No records found") and return 
      end

    # Build new response
    new_response = records.each_with_index.to_h do |record, index|
        [ "record #{index + 1}", "from user #{record.name}  clock-in #{record.clock_in} - clock-out #{record.clock_out} - duration #{record.duration}" ]
    end
    # add data to redis
    $redis.setex(cache_key, 6000, new_response.to_json)
      render_success(data: new_response) and return 
    end
end
