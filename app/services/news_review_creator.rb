# frozen_string_literal: true

class NewsReviewCreator
  include ActiveModel::Model

  TRACKED_ATTRIBUTES = %w[
    title publication_type date support media section author interviewee link plain_text
    audience_size quotation valuation political_factor topic_id
  ].freeze

  attr_reader :news, :reviewer, :attributes, :notes

  validates :news, :reviewer, presence: true
  validate :presence_of_changes

  def self.call(news:, reviewer:, attributes:, notes: nil)
    new(news:, reviewer:, attributes:, notes:).call
  end

  def initialize(news:, reviewer:, attributes:, notes: nil)
    @news = news
    @reviewer = reviewer
    @attributes = attributes.symbolize_keys
    @notes = notes
  end

  def call
    return failure_result(errors.full_messages) unless valid?

    mention_ids_param = sanitized_mention_ids if attributes.key?(:mention_ids)
    return failure_result(invalid_mentions_message) if mention_ids_param == :invalid

    News.transaction do
      previous_mentions = news.mention_ids.sort

      assign_attributes

      mentions_changed = !mention_ids_param.nil? && mention_ids_param.sort != previous_mentions
      tracked_changes = news.changes.slice(*TRACKED_ATTRIBUTES)

      return failure_result('No hay cambios para revisar') if tracked_changes.empty? && !mentions_changed

      news.save!

      unless mention_ids_param.nil?
        news.mention_ids = mention_ids_param
      end

      changeset = build_changeset(previous_mentions, mention_ids_param.nil? ? previous_mentions : mention_ids_param)
      review = news.reviews.create!(
        reviewer:,
        changeset:,
        news_snapshot: build_snapshot,
        notes:,
        reviewed_at: Time.current
      )

      success_result(review)
    end
  rescue ActiveRecord::RecordInvalid => e
    failure_result(e.record.errors.full_messages.presence || e.message)
  end

  private

  def assign_attributes
    updatable_attributes = attributes.except(:mention_ids)
    news.assign_attributes(updatable_attributes)
  end

  def sanitized_mention_ids
    mention_ids = Array(attributes[:mention_ids]).map(&:to_i).uniq
    return [] if mention_ids.empty?

    persisted_mentions = Mention.where(id: mention_ids).pluck(:id)
    if persisted_mentions.sort != mention_ids.sort
      @invalid_mentions = mention_ids - persisted_mentions
      return :invalid
    end

    mention_ids
  end

  def invalid_mentions_message
    return 'Las menciones provistas no son válidas' if @invalid_mentions.blank?

    "Las menciones provistas no son válidas: #{@invalid_mentions.join(', ')}"
  end

  def build_changeset(previous_mentions, new_mentions)
    attribute_changes = news.saved_changes.slice(*TRACKED_ATTRIBUTES)
    transformed_changes = attribute_changes.each_with_object({}) do |(attribute, values), memo|
      before, after = values
      memo[attribute] = {
        'before' => before.as_json,
        'after' => after.as_json
      }
    end

    mention_changes = build_mention_changes(previous_mentions, new_mentions)
    transformed_changes['mention_ids'] = mention_changes if mention_changes

    transformed_changes
  end

  def build_mention_changes(previous_mentions, new_mentions)
    sorted_new = Array(new_mentions).sort
    return if previous_mentions == sorted_new

    {
      'before' => previous_mentions,
      'after' => sorted_new
    }
  end

  def build_snapshot
    snapshot = news.attributes.slice(*TRACKED_ATTRIBUTES).transform_values do |value|
      value.respond_to?(:as_json) ? value.as_json : value
    end
    snapshot['topic'] = build_topic_snapshot
    snapshot['mention_ids'] = news.mention_ids
    snapshot['mention_names'] = news.mentions.pluck(:name)
    snapshot
  end

  def build_topic_snapshot
    return if news.topic.blank?

    { 'id' => news.topic.id, 'name' => news.topic.name }
  end

  def presence_of_changes
    return if attributes.except(:mention_ids).present? || attributes.key?(:mention_ids) || notes.present?

    errors.add(:base, 'Debe enviar al menos un cambio o comentario')
  end

  def success_result(review)
    ServiceResult.new(success: true, payload: review)
  end

  def failure_result(messages)
    ServiceResult.new(success: false, errors: Array(messages))
  end
end
