# frozen_string_literal: true

class ClippingConstraintsValidator < ActiveModel::Validator
  def validate(record)
    return unless record.persisted?

    validate_topic_change(record) if record.will_save_change_to_topic_id?
    validate_date_change(record) if record.will_save_change_to_date?
  end

  private

  def validate_topic_change(record)
    previous_topic_id = record.topic_id_in_database
    return if previous_topic_id.blank?

    blocking_clippings = record.clippings.where(topic_id: previous_topic_id)
    return unless blocking_clippings.exists?

    record.errors.add(:topic_id, :clipping_restriction)
  end

  def validate_date_change(record)
    new_date = record.date
    blocking_clippings = record.clippings.where('start_date > ? OR end_date < ?', new_date, new_date)
    return unless blocking_clippings.exists?

    record.errors.add(:date, :clipping_bounds)
  end
end
