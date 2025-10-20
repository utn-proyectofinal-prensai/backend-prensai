RSpec.describe Clippings::ReportPdfExporter, type: :service do
  subject(:export_pdf) { described_class.call(report) }
  
  let(:clipping) { create(:clipping, topic: create(:topic, name: 'Cultura')) }
  let(:markdown_content) do
    <<~MARKDOWN
      # Reporte de Clipping
      
      ## Resumen Ejecutivo
      
      Este es un reporte de prueba con **texto en negrita** y *cursiva*.
    MARKDOWN
  end
  let(:report) do
    create(:clipping_report, clipping: clipping, content: markdown_content)
  end
  
  describe '.call' do
    it 'returns a successful result with PDF content' do
      result = export_pdf
      
      expect(result).to be_success
      expect(result.payload[:content]).to be_present
      expect(result.payload[:filename]).to include('reporte_clipping_cultura')
      expect(result.payload[:filename]).to end_with('.pdf')
    end
    
    it 'generates a valid PDF file' do
      result = export_pdf
      
      # Verificar que el contenido comienza con el header de PDF
      expect(result.payload[:content]).to start_with('%PDF')
    end
  end
end