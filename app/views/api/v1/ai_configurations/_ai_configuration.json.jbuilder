json.extract! ai_configuration, :key, :value, :value_type, :display_name, :description, :enabled, :reference_type,
              :created_at, :updated_at

json.options ai_configuration.options if ai_configuration.value_type == 'reference'
