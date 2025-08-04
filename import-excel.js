const xlsx = require('xlsx');
const { News } = require('./models');
const path = require('path');

// Función para importar Excel
async function importExcel(filePath) {
  try {
    console.log('📊 Iniciando importación de Excel...');
    console.log('📁 Archivo:', filePath);

    // Leer el archivo Excel
    const workbook = xlsx.readFile(filePath);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    
    // Convertir a JSON
    const jsonData = xlsx.utils.sheet_to_json(worksheet);

    console.log(`📈 Total de filas encontradas: ${jsonData.length}`);
    console.log('📋 Campos disponibles:', Object.keys(jsonData[0] || {}));

    // Procesar cada noticia
    const noticiasImportadas = [];
    const errores = [];

    for (let i = 0; i < jsonData.length; i++) {
      const row = jsonData[i];
      
      try {
        // Mapear campos del Excel a nuestro modelo (nombres exactos del Excel)
        const noticiaData = {
          titulo: row['TITULO'] || '',
          tipoPublicacion: row['TIPO PUBLICACION'] || '',
          fecha: row['FECHA'] ? new Date(row['FECHA']) : new Date(),
          soporte: row['SOPORTE'] || '',
          medio: row['MEDIO'] || '',
          seccion: row['SECCION'] || '',
          autor: row['AUTOR'] || '',
          conductor: row['CONDUCTOR'] || '',
          entrevistado: row['ENTREVISTADO'] || '',
          tema: row['TEMA'] || '',
          etiqueta1: row['ETIQUETA_1'] || '',
          etiqueta2: row['ETIQUETA_2'] || '',
          link: row['LINK'] || '',
          alcance: row['ALCANCE'] || '',
          cotizacion: row['COTIZACION'] || '',
          tapa: row['TAPA'] || '',
          valoracion: row['VALORACION'] || '',
          ejeComunicacional: row['EJE COMUNICACIONAL'] || '',
          factorPolitico: row['FACTOR POLITICO'] || '',
          crisis: row['CRISIS'] || '',
          gestion: row['GESTION'] || '',
          area: row['AREA'] || '',
          mencion1: row['MENCION_1'] || '',
          mencion2: row['MENCION_2'] || '',
          mencion3: row['MENCION_3'] || '',
          mencion4: row['MENCION_4'] || '',
          mencion5: row['MENCION_5'] || '',
          status: 'processed'
        };

        // Crear la noticia en la base de datos
        const noticia = await News.create(noticiaData);
        noticiasImportadas.push(noticia);
        
        console.log(`✅ Fila ${i + 1}: "${noticiaData.titulo.substring(0, 50)}..."`);

      } catch (error) {
        console.error(`❌ Error en fila ${i + 1}:`, error.message);
        errores.push({
          fila: i + 1,
          error: error.message,
          datos: row
        });
      }
    }

    // Mostrar resumen
    console.log('\n📊 RESUMEN DE IMPORTACIÓN:');
    console.log('========================');
    console.log(`✅ Total procesadas: ${jsonData.length}`);
    console.log(`✅ Importadas correctamente: ${noticiasImportadas.length}`);
    console.log(`❌ Errores: ${errores.length}`);

    if (errores.length > 0) {
      console.log('\n⚠️ ERRORES ENCONTRADOS:');
      errores.forEach(error => {
        console.log(`• Fila ${error.fila}: ${error.error}`);
      });
    }

    if (noticiasImportadas.length > 0) {
      console.log('\n✅ NOTICIAS IMPORTADAS:');
      noticiasImportadas.forEach((noticia, index) => {
        console.log(`${index + 1}. ID: ${noticia.id} - "${noticia.titulo}"`);
      });
    }

    console.log('\n🎉 ¡Importación completada!');

  } catch (error) {
    console.error('❌ Error general:', error.message);
  }
}

// Función principal
async function main() {
  try {
    // Verificar argumentos
    const filePath = process.argv[2];
    
    if (!filePath) {
      console.log('❌ Uso: node import-excel.js <ruta-del-archivo-excel>');
      console.log('📋 Ejemplo: node import-excel.js "noticias.xlsx"');
      process.exit(1);
    }

    // Verificar que el archivo existe
    const fs = require('fs');
    if (!fs.existsSync(filePath)) {
      console.log(`❌ El archivo no existe: ${filePath}`);
      process.exit(1);
    }

    // Inicializar la base de datos
    const { sequelize } = require('./models');
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida');

    // Importar el Excel
    await importExcel(filePath);

    // Cerrar conexión
    await sequelize.close();
    console.log('✅ Conexión cerrada');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

// Ejecutar el script
main(); 