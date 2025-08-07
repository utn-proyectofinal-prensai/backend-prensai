const fetch = require('node-fetch');

async function testMetricsEndpoint() {
  try {
    console.log('🧪 Probando endpoint de métricas...\n');

    // Obtener algunas noticias de prueba
    console.log('📰 Obteniendo noticias de prueba...');
    const newsResponse = await fetch('http://localhost:3000/api/news?limit=10');
    const newsData = await newsResponse.json();
    
    if (!newsData.noticias || newsData.noticias.length === 0) {
      console.log('❌ No se encontraron noticias para probar');
      return;
    }

    const newsIds = newsData.noticias.map(n => n.id).slice(0, 5);
    console.log(`✅ Obtenidas ${newsIds.length} noticias para el test`);

    // Probar el endpoint de métricas
    console.log('\n📊 Calculando métricas...');
    const metricsResponse = await fetch('http://localhost:3000/api/news/metrics', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ newsIds: newsIds })
    });

    const data = await metricsResponse.json();

    if (metricsResponse.ok) {
      console.log('✅ Métricas calculadas exitosamente\n');
      
      console.log('📈 RESUMEN GENERAL:');
      console.log(`  - Total noticias: ${data.metricas.totalNoticias}`);
      console.log(`  - Medios únicos: ${data.metricas.resumen.mediosUnicos}`);
      console.log(`  - Temas únicos: ${data.metricas.resumen.temasUnicos}`);
      console.log(`  - Rango de días: ${data.metricas.resumen.rangoDias}`);
      console.log(`  - Fecha más antigua: ${data.metricas.resumen.fechaMasAntigua}`);
      console.log(`  - Fecha más reciente: ${data.metricas.resumen.fechaMasReciente}`);

      // Mostrar análisis de valoración
      if (data.metricas.valoracionAnalysis) {
        console.log('\n📊 ANÁLISIS DE VALORACIÓN:');
        console.log(`  - Total noticias: ${data.metricas.valoracionAnalysis.totalNoticias}`);
        console.log(`  - Valoraciones negativas: ${data.metricas.valoracionAnalysis.negativas.cantidad} (${data.metricas.valoracionAnalysis.negativas.porcentaje}%)`);
        console.log(`  - Valoraciones positivas: ${data.metricas.valoracionAnalysis.positivas.cantidad} (${data.metricas.valoracionAnalysis.positivas.porcentaje}%)`);
        console.log(`  - Valoraciones neutras: ${data.metricas.valoracionAnalysis.neutras.cantidad} (${data.metricas.valoracionAnalysis.neutras.porcentaje}%)`);
        console.log(`  - No especificadas: ${data.metricas.valoracionAnalysis.noEspecificadas.cantidad} (${data.metricas.valoracionAnalysis.noEspecificadas.porcentaje}%)`);
        console.log(`  - ¿Es tema crítico?: ${data.metricas.valoracionAnalysis.esTemaCritico ? 'SÍ' : 'NO'}`);
        
        if (data.metricas.valoracionAnalysis.esTemaCritico) {
          console.log('  🚨 ¡TEMA CRÍTICO! (5 o más valoraciones negativas)');
        } else {
          console.log('  ✅ Tema no crítico (menos de 5 valoraciones negativas)');
        }
      }

      // Mostrar análisis de menciones
      if (data.metricas.mencionesAnalysis) {
        console.log('\n👥 ANÁLISIS DE MENCIONES:');
        console.log(`  - Total noticias: ${data.metricas.mencionesAnalysis.totalNoticias}`);
        console.log(`  - Mención 1 con "Sí": ${data.metricas.mencionesAnalysis.mencion1.cantidad} (${data.metricas.mencionesAnalysis.mencion1.porcentaje}%)`);
        console.log(`  - Mención 2 con "Sí": ${data.metricas.mencionesAnalysis.mencion2.cantidad} (${data.metricas.mencionesAnalysis.mencion2.porcentaje}%)`);
        console.log(`  - Mención 3 con "Sí": ${data.metricas.mencionesAnalysis.mencion3.cantidad} (${data.metricas.mencionesAnalysis.mencion3.porcentaje}%)`);
        console.log(`  - Mención 4 con "Sí": ${data.metricas.mencionesAnalysis.mencion4.cantidad} (${data.metricas.mencionesAnalysis.mencion4.porcentaje}%)`);
        console.log(`  - Mención 5 con "Sí": ${data.metricas.mencionesAnalysis.mencion5.cantidad} (${data.metricas.mencionesAnalysis.mencion5.porcentaje}%)`);
      }

      // Mostrar algunas métricas por categoría
      console.log('\n📋 MÉTRICAS POR CATEGORÍA:');
      
      if (data.metricas.valoracion && data.metricas.valoracion.length > 0) {
        console.log('\n  Valoraciones:');
        data.metricas.valoracion.forEach(item => {
          console.log(`    - ${item.nombre}: ${item.cantidad} (${item.porcentaje}%)`);
        });
      }

      if (data.metricas.medio && data.metricas.medio.length > 0) {
        console.log('\n  Medios:');
        data.metricas.medio.forEach(item => {
          console.log(`    - ${item.nombre}: ${item.cantidad} (${item.porcentaje}%)`);
        });
      }

      if (data.metricas.tema && data.metricas.tema.length > 0) {
        console.log('\n  Temas:');
        data.metricas.tema.forEach(item => {
          console.log(`    - ${item.nombre}: ${item.cantidad} (${item.porcentaje}%)`);
        });
      }

    } else {
      console.log('❌ Error al calcular métricas:', data.error);
    }

  } catch (error) {
    console.error('❌ Error en el test:', error.message);
  }
}

// Ejecutar el test
testMetricsEndpoint(); 