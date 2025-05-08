module JsonResponse
  extend ActiveSupport::Concern

  # Standard JSON response method
  # data: The main data payload (can be a hash, array, or nil)
  # message: A descriptive message (text)
  # status: The HTTP status code (e.g., :ok, :created, :unprocessable_entity, :not_found)
  # meta: Optional metadata (e.g., pagination,etc )
  def render_json(data: nil, message: "success", status: :ok, meta: {})
    response = {
      message: message,
      meta: meta
    }

    response[:data] = data unless data.nil?

    render json: response, status: status
  end

  # For success responses
  def render_success(data: nil, message: "success", status: :ok, meta: {})
    render_json(data: data, message: message, status: status, meta: meta)
  end

  # For error responses
  def render_error(message: "error", status: :unprocessable_entity, meta: {})
    render_json(data: nil, message: message, status: status, meta: meta)
  end
end
