// Script de prueba para verificar la lógica de valoración
console.log('🧪 Probando lógica de valoración...\n');

// Simular las noticias con diferentes valoraciones
const testNoticias = [
  { valoracion: 'Negativa' },
  { valoracion: 'Negativa' },
  { valoracion: 'NO_NEGATIVO' },
  { valoracion: 'Positiva' },
  { valoracion: 'Neutra' }
];

console.log('📊 Noticias de prueba:');
testNoticias.forEach((noticia, index) => {
  console.log(`  ${index + 1}. Valoración: "${noticia.valoracion}"`);
});

// Aplicar la misma lógica que está en el backend
let valoracionesNegativas = 0;
let valoracionesPositivas = 0;
let valoracionesNeutras = 0;
let valoracionesNoEspecificadas = 0;

testNoticias.forEach(noticia => {
  const valoracion = noticia.valoracion ? noticia.valoracion.toString().toLowerCase().trim() : '';
  
  console.log(`\n🔍 Procesando: "${noticia.valoracion}" -> "${valoracion}"`);
  
  if (valoracion === '') {
    valoracionesNoEspecificadas++;
    console.log('  → Clasificado como: No Especificada');
  } else if (valoracion === 'negativa' || valoracion === 'negativo' || valoracion === 'negative') {
    valoracionesNegativas++;
    console.log('  → Clasificado como: Negativa');
  } else if (valoracion === 'positiva' || valoracion === 'positivo' || valoracion === 'positive') {
    valoracionesPositivas++;
    console.log('  → Clasificado como: Positiva');
  } else if (valoracion === 'neutra' || valoracion === 'neutral' || valoracion === 'neutro') {
    valoracionesNeutras++;
    console.log('  → Clasificado como: Neutra');
  } else if (valoracion === 'no_negativo' || valoracion === 'no negativo' || valoracion === 'no_negativa' || valoracion === 'no negativa') {
    valoracionesPositivas++;
    console.log('  → Clasificado como: Positiva (NO_NEGATIVO)');
  } else {
    valoracionesNoEspecificadas++;
    console.log('  → Clasificado como: No Especificada (no coincide con ningún patrón)');
  }
});

// Determinar si el tema es crítico
const esTemaCritico = valoracionesNegativas >= 5;
const totalNoticias = testNoticias.length;

console.log('\n📈 RESULTADOS:');
console.log(`  - Total noticias: ${totalNoticias}`);
console.log(`  - Negativas: ${valoracionesNegativas} (${Math.round((valoracionesNegativas / totalNoticias) * 100)}%)`);
console.log(`  - Positivas: ${valoracionesPositivas} (${Math.round((valoracionesPositivas / totalNoticias) * 100)}%)`);
console.log(`  - Neutras: ${valoracionesNeutras} (${Math.round((valoracionesNeutras / totalNoticias) * 100)}%)`);
console.log(`  - No especificadas: ${valoracionesNoEspecificadas} (${Math.round((valoracionesNoEspecificadas / totalNoticias) * 100)}%)`);
console.log(`  - ¿Es tema crítico?: ${esTemaCritico ? 'SÍ' : 'NO'} (${valoracionesNegativas >= 5 ? '5+ negativas' : '< 5 negativas'})`);

console.log('\n✅ Prueba completada.');
