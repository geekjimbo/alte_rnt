require 'google/api_client'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'

class GoogleDrive
  CREDENTIALS_FILE = Rails.root.join('tmp/google', 'client_secrets.json')
  CREDENTIALS_PATH = Rails.root.join('tmp/google', 'client_secrets.json')

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
  
  def download_this_file(file)
    download_url = file.download_url if file.download_url
	result = ""
    result = @client.execute(uri: download_url) if download_url
    #web_download_url = ""
    #web_download_url = result.body.match(/https.*=download/)[0] if result.body.match(/unauthorized/i).nil?
    #result2 = ""
    #result2 = @client.execute(:uri =>web_download_url) if result.body.match(/unauthorized/i).nil?
    return result
  end
  
  def save_file_to_tmp(output_file_path, result)
    f = File.open(output_file_path, 'w')
    f.write result.body.force_encoding("utf-8")
    f.close
  end

  def get_files_list
    result = @client.execute(
      api_method: @drive.files.list
    )
    file = result.data['items']
    return file
  end
  
  def find_by_url(url)
    id = strip_id_from_url url
    file_list = get_files_list
    resultado = ""
    file_list.each {|f| resultado = f if f.id == id}
    return resultado
  end
  
  def strip_id_from_url(url)
    result = url.match(/\/d\/.*\//)[0].gsub(/\/d\//,"").gsub(/\//,"") 
    #result = url.match(/srcid=.*/)[0].gsub(/srcid=/,"")
    return result
  end
  
  def download_file_by_url(url)
    file = find_by_url url
    result = download_this_file file
    return "Acceso No Autorizado" if result == ""
    file_name = "file_"+Random.new.rand(1..100000).to_s.rjust(7,"0")+".pdf"
    output_file_path = Rails.root.join('tmp/files', file_name)
    save_file_to_tmp output_file_path, result
    return output_file_path.to_s
  end

  def download_file(file)
    result = download_this_file file
    return "Acceso No Autorizado" if result == ""
    file_name = "file_"+Random.new.rand(1..100000).to_s.rjust(7,"0")+".pdf"
    output_file_path = Rails.root.join('tmp/files', file_name)
    save_file_to_tmp output_file_path, result
    return output_file_path.to_s
  end
end
