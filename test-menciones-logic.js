// Script de prueba para verificar la lógica de análisis de menciones
console.log('🧪 Probando lógica de análisis de menciones...\n');

// Simular las noticias con diferentes menciones
const testNoticias = [
  { 
    mencion1: 'Sí', 
    mencion2: 'No', 
    mencion3: 'Sí', 
    mencion4: '', 
    mencion5: 'No' 
  },
  { 
    mencion1: 'No', 
    mencion2: 'Sí', 
    mencion3: 'No', 
    mencion4: 'Sí', 
    mencion5: 'Sí' 
  },
  { 
    mencion1: 'Sí', 
    mencion2: 'Sí', 
    mencion3: 'No', 
    mencion4: 'No', 
    mencion5: 'Sí' 
  },
  { 
    mencion1: 'No', 
    mencion2: 'No', 
    mencion3: 'Sí', 
    mencion4: 'Sí', 
    mencion5: 'No' 
  },
  { 
    mencion1: 'Sí', 
    mencion2: 'No', 
    mencion3: 'Sí', 
    mencion4: 'Sí', 
    mencion5: 'Sí' 
  }
];

console.log('📊 Noticias de prueba:');
testNoticias.forEach((noticia, index) => {
  console.log(`  ${index + 1}. Menciones: [${noticia.mencion1}, ${noticia.mencion2}, ${noticia.mencion3}, ${noticia.mencion4}, ${noticia.mencion5}]`);
});

// Aplicar la misma lógica que está en el backend
let menciones1ConSi = 0;
let menciones2ConSi = 0;
let menciones3ConSi = 0;
let menciones4ConSi = 0;
let menciones5ConSi = 0;

// Función helper para verificar si una mención tiene "Sí" o derivados
const tieneMencionSi = (mencion) => {
  if (!mencion) return false;
  const mencionLower = mencion.toString().toLowerCase().trim();
  return mencionLower === 'sí' || mencionLower === 'si' || mencionLower === 'yes' || 
         mencionLower === 'true' || mencionLower === 'verdadero' || mencionLower === '1';
};

testNoticias.forEach((noticia, index) => {
  console.log(`\n🔍 Procesando noticia ${index + 1}:`);
  console.log(`  Mención 1: "${noticia.mencion1}" -> ${tieneMencionSi(noticia.mencion1) ? 'SÍ' : 'NO'}`);
  console.log(`  Mención 2: "${noticia.mencion2}" -> ${tieneMencionSi(noticia.mencion2) ? 'SÍ' : 'NO'}`);
  console.log(`  Mención 3: "${noticia.mencion3}" -> ${tieneMencionSi(noticia.mencion3) ? 'SÍ' : 'NO'}`);
  console.log(`  Mención 4: "${noticia.mencion4}" -> ${tieneMencionSi(noticia.mencion4) ? 'SÍ' : 'NO'}`);
  console.log(`  Mención 5: "${noticia.mencion5}" -> ${tieneMencionSi(noticia.mencion5) ? 'SÍ' : 'NO'}`);
  
  if (tieneMencionSi(noticia.mencion1)) menciones1ConSi++;
  if (tieneMencionSi(noticia.mencion2)) menciones2ConSi++;
  if (tieneMencionSi(noticia.mencion3)) menciones3ConSi++;
  if (tieneMencionSi(noticia.mencion4)) menciones4ConSi++;
  if (tieneMencionSi(noticia.mencion5)) menciones5ConSi++;
});

const totalNoticias = testNoticias.length;

console.log('\n📈 RESULTADOS DEL ANÁLISIS DE MENCIONES:');
console.log(`  - Total noticias: ${totalNoticias}`);
console.log(`  - Mención 1 con "Sí": ${menciones1ConSi} (${Math.round((menciones1ConSi / totalNoticias) * 100)}%)`);
console.log(`  - Mención 2 con "Sí": ${menciones2ConSi} (${Math.round((menciones2ConSi / totalNoticias) * 100)}%)`);
console.log(`  - Mención 3 con "Sí": ${menciones3ConSi} (${Math.round((menciones3ConSi / totalNoticias) * 100)}%)`);
console.log(`  - Mención 4 con "Sí": ${menciones4ConSi} (${Math.round((menciones4ConSi / totalNoticias) * 100)}%)`);
console.log(`  - Mención 5 con "Sí": ${menciones5ConSi} (${Math.round((menciones5ConSi / totalNoticias) * 100)}%)`);

console.log('\n✅ Prueba de análisis de menciones completada.');
