class GoogleController < ApplicationController
  def oauth
    client = Signet::OAuth2::Client.new(client_options)

    redirect_to client.authorization_uri.to_s, allow_other_host: true
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)
    client.code = params[:code]

    response = client.fetch_access_token!

    session[:authorization] = response

    redirect_to new_event_path
  end

  def create
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    start_time = params[:date_time].to_datetime.change(offset: '-0500').rfc3339
    end_time = params[:end_time].to_datetime.change(offset: '-0500').rfc3339

    event = Google::Apis::CalendarV3::Event.new(
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time),
      end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time),
      summary: params[:title],
      description: params[:description]
    )

    service.insert_event('primary', event)

    redirect_to root_path
  rescue Google::Apis::AuthorizationError
    response = client.refresh!

    session[:authorization] = session[:authorization].merge(response)

    retry
  end

  private

  def event_params
    params.permit(:title, :description, :date_time)
  end

  def client_options
    {
      client_id: ENV['google_client_id'],
      client_secret: ENV['google_client_secret'],
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: 'http://localhost:3000/callback'
    }
  end
end
