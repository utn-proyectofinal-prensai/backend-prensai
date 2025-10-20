module Clippings
  class ReportPdfExporter
    include ActiveModel::Model
    
    attr_reader :report
    
    def self.call(report)
      new(report).call
    end
    
    def initialize(report)
      @report = report
    end
    
    def call
      html_content = build_html_content
      pdf_content = generate_pdf(html_content)
      success_result(pdf_content, filename)
    rescue StandardError => error
      Rails.logger.error "ReportPdfExporter error: #{error.message}"
      failure_result("Error generando PDF: #{error.message}")
    end
    
    private
    
    def build_html_content
      markdown_html = convert_markdown_to_html(report.content)
      
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>Reporte de Clipping</title>
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
              line-height: 1.6;
              color: #333;
              max-width: 800px;
              margin: 0 auto;
              padding: 40px 20px;
            }
            h1, h2, h3, h4, h5, h6 {
              margin-top: 24px;
              margin-bottom: 16px;
              font-weight: 600;
              line-height: 1.25;
            }
            h1 {
              font-size: 2em;
              border-bottom: 1px solid #eaecef;
              padding-bottom: 0.3em;
            }
            h2 {
              font-size: 1.5em;
              border-bottom: 1px solid #eaecef;
              padding-bottom: 0.3em;
            }
            h3 { font-size: 1.25em; }
            h4 { font-size: 1em; }
            p {
              margin-bottom: 16px;
            }
            ul, ol {
              margin-bottom: 16px;
              padding-left: 2em;
            }
            li {
              margin-bottom: 0.25em;
            }
            code {
              background-color: #f6f8fa;
              padding: 0.2em 0.4em;
              border-radius: 3px;
              font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
              font-size: 85%;
            }
            pre {
              background-color: #f6f8fa;
              padding: 16px;
              border-radius: 6px;
              overflow-x: auto;
            }
            pre code {
              background-color: transparent;
              padding: 0;
            }
            blockquote {
              padding: 0 1em;
              color: #6a737d;
              border-left: 0.25em solid #dfe2e5;
              margin: 0 0 16px 0;
            }
            table {
              border-collapse: collapse;
              width: 100%;
              margin-bottom: 16px;
            }
            table th,
            table td {
              padding: 6px 13px;
              border: 1px solid #dfe2e5;
            }
            table th {
              background-color: #f6f8fa;
              font-weight: 600;
            }
            table tr {
              background-color: #fff;
            }
            table tr:nth-child(2n) {
              background-color: #f6f8fa;
            }
            .header {
              text-align: center;
              margin-bottom: 40px;
              padding-bottom: 20px;
              border-bottom: 2px solid #0366d6;
            }
            .header h1 {
              color: #0366d6;
              border: none;
              margin: 0;
            }
            .metadata {
              background-color: #f6f8fa;
              padding: 16px;
              border-radius: 6px;
              margin-bottom: 30px;
              font-size: 0.9em;
            }
            .metadata p {
              margin: 4px 0;
            }
            .footer {
              margin-top: 40px;
              padding-top: 20px;
              border-top: 1px solid #eaecef;
              text-align: center;
              font-size: 0.85em;
              color: #6a737d;
            }
            hr {
              height: 0.25em;
              padding: 0;
              margin: 24px 0;
              background-color: #e1e4e8;
              border: 0;
            }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>Reporte de Clipping</h1>
          </div>
          
          <div class="metadata">
            <p><strong>Tema:</strong> #{report.clipping.topic&.name || 'Sin tema'}</p>
            <p><strong>Período:</strong> #{date_range_text}</p>
            <p><strong>Generado:</strong> #{report.created_at.strftime('%d/%m/%Y %H:%M')}</p>
            #{creator_info}
            #{reviewer_info}
          </div>
          
          <div class="content">
            #{markdown_html}
          </div>
          
          <div class="footer">
            <p>Generado por PrensAI - #{Time.current.strftime('%d/%m/%Y')}</p>
          </div>
        </body>
        </html>
      HTML
    end
    
    def convert_markdown_to_html(markdown_text)
      return '' if markdown_text.blank?
      
      renderer = Redcarpet::Render::HTML.new(
        filter_html: false,
        hard_wrap: true,
        link_attributes: { target: '_blank' }
      )
      
      markdown = Redcarpet::Markdown.new(
        renderer,
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        superscript: true,
        underline: true,
        highlight: true,
        footnotes: true
      )
      
      markdown.render(markdown_text)
    end
    
    def generate_pdf(html_content)
      Grover.new(html_content, **grover_options).to_pdf
    end
    
    def grover_options
      {
        format: 'A4',
        margin: {
          top: '1cm',
          bottom: '1cm',
          left: '1.5cm',
          right: '1.5cm'
        },
        print_background: true,
        prefer_css_page_size: false,
        display_header_footer: true,
        header_template: header_template,
        footer_template: footer_template,
        wait_until: 'networkidle0'
      }
    end
    
    def header_template
      <<~HTML
        <div style="width: 100%; font-size: 10px; padding: 5px 15px; text-align: center; color: #666;">
          <span>#{report.clipping.topic&.name || 'Reporte de Clipping'}</span>
        </div>
      HTML
    end
    
    def footer_template
      <<~HTML
        <div style="width: 100%; font-size: 10px; padding: 5px 15px; display: flex; justify-content: space-between; color: #666;">
          <span>PrensAI - #{Date.current.strftime('%d/%m/%Y')}</span>
          <span>Página <span class="pageNumber"></span> de <span class="totalPages"></span></span>
        </div>
      HTML
    end
    
    def date_range_text
      start_date = report.clipping.start_date&.strftime('%d/%m/%Y')
      end_date = report.clipping.end_date&.strftime('%d/%m/%Y')
      
      if start_date && end_date
        "#{start_date} - #{end_date}"
      elsif start_date
        "Desde #{start_date}"
      elsif end_date
        "Hasta #{end_date}"
      else
        "Sin período definido"
      end
    end
    
    def creator_info
      return '' unless report.creator.present?
      
      "<p><strong>Creado por:</strong> #{report.creator.full_name}</p>"
    end
    
    def reviewer_info
      return '' unless report.reviewer.present?
      
      "<p><strong>Revisado por:</strong> #{report.reviewer.full_name}</p>"
    end
    
    def filename
      topic_name = report.clipping.topic&.name&.parameterize || 'sin_tema'
      date = Date.current.strftime('%Y%m%d')
      "reporte_clipping_#{topic_name}_#{date}.pdf"
    end
    
    def success_result(content, filename)
      ServiceResult.new(
        success: true, 
        payload: {
          content: content,
          filename: filename
        }
      )
    end
    
    def failure_result(errors)
      ServiceResult.new(success: false, errors: Array.wrap(errors))
    end
  end
end