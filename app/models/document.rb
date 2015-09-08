class Document < ActiveRecord::Base
  has_attached_file :file
  validates_attachment :file,
    :size => { :in => 1..40.megabytes }
  do_not_validate_attachment_file_type :file

  after_save :update_kami_document, if: :file_updated_at_changed?

  def update_kami_document
    payload = {
      "document_url": file.expiring_url,
      "name": name,
    }
    p payload
    response = JSON[RestClient.post 'https://api.notablepdf.com/embed/documents', payload.to_json, {
      :content_type => 'application/json',
      :authorization => "Token #{ENV['KAMI_API_KEY']}"
    }]

    update_column(:kami_document_id, response['document_identifier'])
  end


  def session_view_url
    return  unless kami_document_id.present?
    payload = {
      "document_identifier": kami_document_id,
      # We don't have user accounts in this sample app, but in a real one you'd include the user ID here.
       "user": {
         "name": "Test User",
         "user_id": 1
       },
       "expires_at": 60.minutes.from_now
    }

    response = JSON[RestClient.post 'https://api.notablepdf.com/embed/sessions', payload.to_json, {
      :content_type => 'application/json',
      :authorization => "Token #{ENV['KAMI_API_KEY']}"
    }]

    p response
    response['viewer_url']
  end
end
