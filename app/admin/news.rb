# frozen_string_literal: true

ActiveAdmin.register News do
  actions :index, :show, :destroy

  includes :topic, :creator, :reviewer

  filter :id
  filter :title
  filter :media
  filter :support
  filter :valuation, as: :select, collection: News.valuations.keys.map { |key| [key.humanize, key] }
  filter :topic
  filter :date
  filter :created_at

  index do
    selectable_column
    id_column
    column :title
    column :media
    column :support
    column :valuation do |news|
      news.valuation&.humanize || 'N/A'
    end
    column :date
    column :topic
    column :created_at
    actions defaults: false do |news|
      item t('active_admin.view'), resource_path(news), class: 'view_link member_link'
      item t('active_admin.delete'), resource_path(news),
           method: :delete,
           data: { confirm: I18n.t('active_admin.delete_confirmation', model: news.title) },
           class: 'delete_link member_link'
    end
  end

  show do
    attributes_table do
      row :id
      row :title
      row :date
      row :media
      row :support
      row :publication_type
      row :valuation
      row :topic
      row :author
      row :interviewee
      row :political_factor
      row :audience_size
      row :quotation
      row :link
      row :created_at
      row :updated_at
      row :plain_text
    end

    active_admin_comments
  end
end
