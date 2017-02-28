require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'

APPLICATION_NAME = 'sutel'
CLIENT_SECRETS_PATH = 'client_secrets.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "client_secrets.json")
                            # "drive-ruby-quickstart.json")
SCOPE = 'https://www.googleapis.com/auth/drive.metadata.readonly'

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization request via InstalledAppFlow.
# If authorization is required, the user's default browser will be launched
# to approve the request.
#
# @return [Signet::OAuth2::Client] OAuth2 credentials
def ruby_gdrive
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
    storage = Google::APIClient::Storage.new(file_store)
    auth = storage.authorize

    if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
      app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
      flow = Google::APIClient::InstalledAppFlow.new({
        :client_id => app_info.client_id,
        :client_secret => app_info.client_secret,
        :scope => SCOPE})
      auth = flow.authorize(storage)
      puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
    end
    auth
  end

  def setup_gdrive
    # Initialize the API
    client = Google::APIClient.new(:application_name => APPLICATION_NAME)
    client.authorization = authorize
    drive_api = client.discovered_api('drive', 'v2')
    return client, drive_api
  end

  def get_10_files
    #setup gdrive
    client, drive_api = setup_gdrive
    # List the 10 most recently modified files.
    results = client.execute!(
      :api_method => drive_api.files.list,
      :parameters => { :maxResults => 10 })
    resultado = ""
    resultado += "Files: \n"
    resultado += "No files found" if results.data.items.empty?
    results.data.items.each do |file|
      resultado += "#{file.title} (#{file.id})\n"
    end
    return resultado
  end
  
  def get_first_file
    #setup gdrive
    client, drive_api = setup_gdrive
    # List the 10 most recently modified files.
    results = client.execute!(
      :api_method => drive_api.files.list,
      :parameters => { :maxResults => 10 })
    resultado = "" if results.data.items.empty?
    resultado = results.data.items[2]
    #results.data.items.each do |file|
      #resultado += "#{file.title} (#{file.id})\n"
    #end
    return resultado
  end

  def download_first_file
    #setup gdrive
    client, drive_api = setup_gdrive
    file = get_first_file
    result = client.execute(:uri => file.download_url)
    return result
    if file.download_url
      result = client.execute(:uri => file.download_url)
      if result.status == 200
        return result.body
      else
        puts "An error occurred: #{result.data['error']['message']}"
        return nil
      end
    else
      # The file doesn't have any content stored on Drive.
      return nil
    end
  end  
end
