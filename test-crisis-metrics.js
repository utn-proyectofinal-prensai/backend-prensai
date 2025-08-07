import fetch from 'node-fetch';

async function testCrisisMetrics() {
  try {
    console.log('🧪 Probando métrica de crisis...\n');
    
    // Primero, vamos a obtener algunas noticias para tener IDs válidos
    const newsResponse = await fetch('http://localhost:3000/api/news?limit=10');
    
    if (!newsResponse.ok) {
      console.log('❌ No se pudieron obtener noticias para la prueba');
      return;
    }
    
    const newsData = await newsResponse.json();
    const newsIds = newsData.noticias.map(n => n.id).slice(0, 5); // Tomar las primeras 5 noticias
    
    console.log(`📊 Probando con ${newsIds.length} noticias:`, newsIds);
    
    const response = await fetch('http://localhost:3000/api/news/metrics', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        newsIds: newsIds
      })
    });

    console.log(`📊 Status: ${response.status}`);
    console.log(`📊 Status Text: ${response.statusText}`);
    
    if (response.ok) {
      const data = await response.json();
      console.log('✅ Respuesta exitosa:');
      
             // Mostrar análisis de crisis específicamente
       if (data.metricas.crisisAnalysis) {
         console.log('\n🚨 ANÁLISIS DE CRISIS:');
         console.log(`  - Total noticias: ${data.metricas.crisisAnalysis.totalNoticias}`);
         console.log(`  - Noticias críticas: ${data.metricas.crisisAnalysis.criticas.cantidad} (${data.metricas.crisisAnalysis.criticas.porcentaje}%)`);
         console.log(`  - Noticias no críticas: ${data.metricas.crisisAnalysis.noCriticas.cantidad} (${data.metricas.crisisAnalysis.noCriticas.porcentaje}%)`);
         console.log(`  - No especifica: ${data.metricas.crisisAnalysis.noEspecifica.cantidad} (${data.metricas.crisisAnalysis.noEspecifica.porcentaje}%)`);
         console.log(`  - Nivel de crisis: ${data.metricas.crisisAnalysis.nivelCrisis}`);
        
        // Mostrar las noticias con su campo crisis para verificar
        console.log('\n📋 Detalle de noticias analizadas:');
        newsData.noticias.slice(0, 5).forEach((noticia, index) => {
          console.log(`  ${index + 1}. "${noticia.titulo}" - Crisis: "${noticia.crisis}"`);
        });
      } else {
        console.log('❌ No se encontró el análisis de crisis en la respuesta');
      }
      
      // Mostrar otras métricas también
      console.log('\n📊 Otras métricas:');
      console.log(`  - Total noticias: ${data.metricas.totalNoticias}`);
      console.log(`  - Soportes únicos: ${data.metricas.resumen.soportesUnicos}`);
      console.log(`  - Medios únicos: ${data.metricas.resumen.mediosUnicos}`);
      console.log(`  - Temas únicos: ${data.metricas.resumen.temasUnicos}`);
      
    } else {
      const errorText = await response.text();
      console.log('❌ Error en la respuesta:');
      console.log(errorText);
    }
    
  } catch (error) {
    console.error('❌ Error de conexión:', error.message);
  }
}

testCrisisMetrics();
