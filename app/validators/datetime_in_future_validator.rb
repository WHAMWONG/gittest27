class DatetimeInFutureValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value <= Time.current
      record.errors.add(attribute, 'must be in the future')
    end
  end
end

Rails.application.config.to_prepare do
  ActiveSupport::Dependencies.autoload_paths << File.expand_path('../validators', __FILE__)
end
