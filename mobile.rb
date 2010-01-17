require 'sinatra'
require 'haml'

helpers do
  
  # Regexes to match identifying portions of UA strings from iPhone and Android
  def mobile_user_agent_patterns
    [
      /AppleWebKit.*Mobile/,
      /Android.*AppleWebKit/
    ]
  end
  
  # Compares User Agent string against regexes of designated mobile devices
  def mobile_request? 
    mobile_user_agent_patterns.any? {|r| request.env['HTTP_USER_AGENT'] =~ r}
  end
  
  # If there is a mobile version of the view, use that. Otherwise revert to normal view
  def mobile_file(name)
    mobile_file = "#{options.views}/#{name}#{@mobile}.haml"
    if File.exist? mobile_file
      view = "#{name}#{@mobile}"
    else
      view = name
    end
  end
  
  # Set up rendering for partials
  def partial(name)
    haml mobile_file("_#{name}").to_sym, :layout => false
  end
  
  # Render appropriate file, with mobile layout if needed
  def deliver(name)
    haml mobile_file(name).to_sym, :layout => :"layout#{@mobile}"
  end
end

# Before responding to each request, verify if it came from a designated mobile device and set @mobile appropriately
before do
  mobile_request? ? @mobile = ".mobile" : @mobile = ""
end

# homepage
get '/' do
  deliver :index
end

# content page (like Other)
get '/:page/' do
  deliver :"#{params[:page]}"
end
