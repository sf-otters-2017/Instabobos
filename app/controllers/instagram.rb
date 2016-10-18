# THE FLOW of OAuth 2.0

# Step 0:   Provide a way to manage a ridirect to the third party login

# Step 1:   Redirect the users to the third party Auth url. This redirect 
#           usually require send some query params to notify the third party
#           who you are and where are you comming from.

# Step 2:   The third party service will responde back to your application to
#           the callback URL. In this case they are responding with a code.
#           Look the what the params have.

# Step 3:   Once you have the code. Format a Post request to get an access token
#           and some Users information. Inspect the response out of that Post.
#           Use this info to create a user in your DB save and the token
#           in the sessions hash.

# Step 4:   Use the access token saved in the session hash to consume the API

            


# ##################### API WRAPER CONFIGURATION #######################
# ----------------------------------------------------------------------

# Make sure you register a callback URL with the third party
CALLBACK_URL = "http://localhost:9393/auth/callback"


# Here your cerdentials. You can allocate this somewhere else. Environment file
# would be a good place. Id and secret better to be saved in an .env file.
Instagram.configure do |config|
  config.client_id = "2b089c3e792e413e83df3xxx"
  config.client_secret = "528659e2e55b4e479xxxx"
end

# ---------------------------------------------------------------------



# ##################### AUTH AND CONSUPTION FLOW #######################
# ----------------------------------------------------------------------

# Step 0: Provide a way to manage a ridirect to the third party login mechanism.
get '/' do

  # Link to: get /auth/connect
  '<a href="/auth/connect">
    <img src="http://i.kinja-img.com/gawker-media/image/upload/t_original/ijmyfpjavgey76pyxnft.jpg">
  </a>'
end

# Step 1: Redirect to third party login.
get '/auth/connect' do
  
  # Redirects to instagram OAuth URL and passes the your callback and extra info
  p url = Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
  
  redirect url
end

# Step 2: CALLBACK_URL registred on third party
get "/auth/callback" do

  p '#### The code comming back from the third party ####'
  p params
  p '####################################################'


# Use the code to format a post request to the third party and request an
# access token.
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)

# Step 3: Save user info and access token
  p "##########   accsess_token ##############"
  p response.access_token
  p "--------------------------------------"
  p "##########    user info    ##############"
  p response
  p "--------------------------------------"

  session[:access_token] = response.access_token

  redirect "/user_recent_media"
end

get "/user_recent_media" do
  
# Step 4: Consume the API  
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  recent_media = client.user_recent_media


  # You now can use third party data in your views
  html = "<h1>#{user.username}'s recent media</h1>"
  for media_item in recent_media
    html << "<div style='float:left;'><img src='#{media_item.images.thumbnail.url}'></div>"
  end

  html
end

# ----------------------------------------------------------------------