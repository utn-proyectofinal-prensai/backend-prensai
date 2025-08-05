import fetch from 'node-fetch';

async function testMetricsEndpoint() {
  try {
    console.log('🧪 Probando endpoint de métricas...\n');
    
    const response = await fetch('http://localhost:3000/api/news/metrics', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        newsIds: ['63', '62', '61']
      })
    });

    console.log(`📊 Status: ${response.status}`);
    console.log(`📊 Status Text: ${response.statusText}`);
    
    if (response.ok) {
      const data = await response.json();
      console.log('✅ Respuesta exitosa:');
      console.log(JSON.stringify(data, null, 2));
    } else {
      const errorText = await response.text();
      console.log('❌ Error en la respuesta:');
      console.log(errorText);
    }
    
  } catch (error) {
    console.error('❌ Error de conexión:', error.message);
  }
}

testMetricsEndpoint(); 