require 'google/api_client'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'

class GoogleDrive
  #CREDENTIALS_FILE = Rails.root.join('tmp', 'client_secrets.json')
  #CREDENTIALS_FILE = './client_secrets.json'
  CREDENTIALS_FILE = Rails.root.join('', 'client_secrets.json')
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',"client_secrets.json")

  def initialize
    credentials_storage = ::Google::APIClient::FileStorage.new(CREDENTIALS_PATH)
    @client = ::Google::APIClient.new(
      application_name:    'sutel'
    )
    @client.authorization = credentials_storage.authorization || begin
      installed_app_flow = ::Google::APIClient::InstalledAppFlow.new(
        client_id:     Settings.google.api.client_id,
        client_secret: Settings.google.api.client_secret,
        scope:         Settings.google.api.scope
      )
      installed_app_flow.authorize(credentials_storage)
    end
    @drive = @client.discovered_api('drive', 'v2')
  end

  def download_latest_file
    result = @client.execute(
      api_method: @drive.files.list
    )
    file = result.data['items'][15]
    download_url = file.web_content_link
    result = @client.execute(uri: download_url)
    web_download_url = result.body.match(/https.*=download/)[0]
    result = @client.execute(:uri =>web_download_url)
    output_file = "/Users/jimmyfigueroa/sites/sample_app/tmp/out_file4.pdf"
    f = File.open(output_file, 'w')
    f.write result.body.force_encoding("utf-8")
    f.close
  end
end