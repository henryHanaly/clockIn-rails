class SleepRecordController < ApplicationController
  def clock_in
    # implement redis for handling idempotency - expecting Front end to adding header with key Idempotency-Key (clockin-timestamp-clockin)
    key_idempotency = request.headers["Idempotency-Key"]
    key_redis = "user:#{@current_user.id}:#{key_idempotency}"

    if key_idempotency.present?
      responsec = $redis.get(key_redis)
      if responsec.present?
        render json: { errors: "Please wait for a while!" }, status: :unprocessable_entity and return
      end
    end

    if sleep_record_validate.present?
      render json: { errors: "Please clock out first before creating a new one" }, status: :unprocessable_entity
    else
      sleep_record = @current_user.sleep_records.create(clock_in: Time.current)
        if sleep_record.persisted?
          # set redis after insert into db
          $redis.setex(key_redis, 180, "clock in success")
          render json: {
            data: {},
            message: "clock in success ",
            meta: {}
            }, status: :created
        else
          render json: { errors: sleep_record.errors.full_messages }, status: :unprocessable_entity
        end
    end
    rescue StandardError => e
      render json: { error:  e }, status: :unprocessable_entity
  end
  def clock_out
    if sleep_record_validate.present?
      now = Time.current
      duration = (now -  sleep_record_validate.clock_in).to_i
      sleep_record_validate.update(clock_out: now, duration: duration)
      render json: {
        data: {},
        message: "clock out success with duration of sleep #{duration}",
        meta: {}
        }, status: :ok
    else
      render json: { error: "No active sleep record found to clock out." }, status: :not_found
    end
    rescue StandardError => e
      render json: { error:  e }, status: :unprocessable_entity
  end

  def index
    records = @current_user.sleep_records.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    # adding pagination
    render json: {
          data: records,
          message: "Success",
          meta: meta_pagination(records)
        }, status: :ok
  end

private

  def sleep_record_validate
     @current_user.sleep_records.where(clock_out: nil).where.not(clock_in: nil).order(clock_in: :desc).select([ :id, :user_id, :clock_in, :clock_out ]).last
  end
end
