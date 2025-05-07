class ApplicationController < ActionController::API
    before_action :authorize_request

  # Use Rails secret key base as the secret for encoding JWT tokens.
  SECRET_KEY = Rails.application.secret_key_base

  # Encodes a payload with an expiration (default 24 hours)
  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  # Decodes a JWT token and returns the payload if valid; otherwise returns nil.
  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  private

  # Checks if the request includes a valid JWT token
  def authorize_request
    token = request.headers["Authorization"]&.split(" ")&.last
    decoded = jwt_decode(token)
    if decoded && decoded[:user_id]
      @current_user = User.find_by(id: decoded[:user_id])
    end

    render json: { errors: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def meta_pagination(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end
