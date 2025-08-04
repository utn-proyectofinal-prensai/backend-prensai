const xlsx = require('xlsx');

function checkExcelColumns(filePath) {
  try {
    console.log('📊 Analizando estructura del Excel...');
    console.log('📁 Archivo:', filePath);

    // Leer el archivo Excel
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    
    // Convertir a JSON
    const jsonData = xlsx.utils.sheet_to_json(worksheet);

    console.log(`📈 Total de filas: ${jsonData.length}`);
    
    if (jsonData.length > 0) {
      console.log('\n📋 NOMBRES EXACTOS DE LAS COLUMNAS:');
      console.log('=====================================');
      Object.keys(jsonData[0]).forEach((columna, index) => {
        console.log(`${index + 1}. "${columna}"`);
      });

      console.log('\n📄 PRIMERA FILA DE DATOS:');
      console.log('==========================');
      const primeraFila = jsonData[0];
      Object.keys(primeraFila).forEach(columna => {
        const valor = primeraFila[columna];
        console.log(`• "${columna}": "${valor}"`);
      });
    }

    console.log('\n✅ Análisis completado');

  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Verificar argumentos
const filePath = process.argv[2];

if (!filePath) {
  console.log('❌ Uso: node check-excel-columns.js <ruta-del-archivo-excel>');
  console.log('📋 Ejemplo: node check-excel-columns.js "noticias.xlsx"');
  process.exit(1);
}

// Ejecutar el análisis
checkExcelColumns(filePath); 