# frozen_string_literal: true

ActiveAdmin.register AiConfiguration do
  permit_params :key, :display_name, :description, :enabled, :value_type, :value, :reference_type

  scope :all, default: true
  scope :enabled

  filter :key
  filter :display_name
  filter :value_type, as: :select, collection: %w[array string reference]
  filter :enabled
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :key
    column :display_name
    column :value_type
    column :reference_type
    column :enabled
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :key
      row :display_name
      row :description
      row :value_type
      row :reference_type
      row :enabled
      row :value do |resource|
        value = resource.value

        if value.is_a?(Array) || value.is_a?(Hash)
          pre JSON.pretty_generate(value)
        else
          value
        end
      rescue StandardError
        value
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'AI Configuration' do
      f.input :key, input_html: { readonly: f.object.persisted? }
      f.input :display_name
      f.input :description
      f.input :value_type, as: :select, collection: AiConfiguration::VALUE_TYPES, include_blank: false
      f.input :reference_type, as: :select, collection: AiConfiguration::REFERENCE_TYPES, include_blank: true
      f.input :enabled
      f.input :value, as: :text,
                      input_html: {
                        rows: 8,
                        value: begin
                          existing_value = f.object.value
                          if existing_value.is_a?(Array) || existing_value.is_a?(Hash)
                            JSON.pretty_generate(existing_value)
                          else
                            existing_value
                          end
                        rescue StandardError
                          f.object.value
                        end
                      },
                      hint: [
                        'For arrays provide valid JSON (e.g. ["foo", "bar"]).',
                        'For references provide the numeric ID.'
                      ].join(' ')
    end

    f.actions
  end

  controller do
    private

    def resource_params
      super.map do |attributes|
        value_type = attributes[:value_type]
        normalized_reference_type = value_type == 'reference' ? attributes[:reference_type].presence : nil

        attributes.merge(
          value: parse_value(attributes[:value], value_type),
          reference_type: normalized_reference_type
        )
      end
    end

    def parse_value(raw_value, value_type)
      return if raw_value.blank?

      return parse_array_value(raw_value) if value_type == 'array'
      return parse_reference_value(raw_value) if value_type == 'reference'

      raw_value
    rescue JSON::ParserError
      raw_value
    end

    def parse_array_value(raw_value)
      parsed = JSON.parse(raw_value)
      parsed.is_a?(Array) ? parsed : raw_value
    end

    def parse_reference_value(raw_value)
      raw_value.to_s.match?(/\A\d+\z/) ? raw_value.to_i : raw_value
    end
  end
end
