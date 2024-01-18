json.attachment do
  json.id @attachment.id
  json.todo_id @attachment.todo_id
  json.file do
    json.url url_for(@attachment.file)
    json.filename @attachment.file.filename.to_s
    json.content_type @attachment.file.content_type
  end
end
