module ApplicationHelpers

  def link_to(text, url, opts = {})
    attributes = ''
    opts.each do |k, v|
      attributes << k.to_s << "=\"" << v << "\" " if k && v
    end
    %(<a href="#{url}" #{attributes}>#{text}</a>)
  end

  def h(text)
    Rack::Utils::escape_html(text)
  end



  def halt_error(status_code=status, message: nil)
    @title   = "Error #{status_code}"
    @status  = status_code || status
    @message = message     || error_messages[@status.to_i]
    halt erb(:error)
  end
  def error_messages
    {
      200 => "OK", 
      400 => "Bad Request", 
      401 => "Unauthorized", 
      403 => "Forbidden", 
      404 => "Not Found", 
      408 => "Request Timeout", 
      410 => "Gone", 
      429 => "Too Many Requests", 
      500 => "Internal Server Error", 
      501 => "Not Implemented", 
      502 => "Bad Gateway", 
      503 => "Service Unavailable", 
      504 => "Gateway Timeout", 
      508 => "Loop Detected", 
    }
  end

end
# include ApplicationHelpers
