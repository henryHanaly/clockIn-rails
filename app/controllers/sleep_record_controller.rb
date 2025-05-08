class SleepRecordController < ApplicationController
  def clock_in
    # implement redis for handling idempotency - expecting Front end to adding header with key Idempotency-Key (clockin-timestamp-clockin)
    key_idempotency = request.headers["Idempotency-Key"]
    key_redis = "user:#{@current_user.id}:#{key_idempotency}"

    if key_idempotency.present?
      responsec = $redis.get(key_redis)
      if responsec.present?
        render_error(message: "Please wait for a while!") and return
      end
    end

    if sleep_record_validate.present?
      render_error(message: "Please clock out first before creating a new one")
    else
      sleep_record = @current_user.sleep_records.create(clock_in: Time.current)
        if sleep_record.persisted?
          # set redis after insert into db
          $redis.setex(key_redis, 180, "clock in success")
          render_success(message: "clock in success", status: :created)
        else
          render_error(message: sleep_record.errors.full_messages)
        end
    end
    rescue StandardError => e
      render_error(message: e)
  end
  def clock_out
    if sleep_record_validate.present?
      now = Time.current
      duration = (now -  sleep_record_validate.clock_in).to_i
      sleep_record_validate.update(clock_out: now, duration: duration)
        render_success(message: "clock out success with duration of sleep #{duration}", status: :created)
    else
      render_error(message: "No active sleep record found to clock out.")
    end
    rescue StandardError => e
      render_error(message: e)
  end

  def index
    records = @current_user.sleep_records.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    # adding pagination
    render_success(message: "success", status: :created, data: records, meta: meta_pagination(records))
  end

private

  def sleep_record_validate
     @current_user.sleep_records.where(clock_out: nil).where.not(clock_in: nil).order(clock_in: :desc).select([ :id, :user_id, :clock_in, :clock_out ]).last
  end
end
