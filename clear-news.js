const { News } = require('./models');

async function clearNews() {
  try {
    console.log('🗑️ Limpiando noticias existentes...');

    // Conectar a la base de datos
    const { sequelize } = require('./models');
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida');

    // Contar noticias existentes
    const totalNoticias = await News.count();
    console.log(`📊 Noticias existentes: ${totalNoticias}`);

    if (totalNoticias > 0) {
      // Eliminar todas las noticias
      await News.destroy({ where: {} });
      console.log('✅ Todas las noticias eliminadas');
    } else {
      console.log('ℹ️ No hay noticias para eliminar');
    }

    // Verificar que se eliminaron
    const noticiasRestantes = await News.count();
    console.log(`📊 Noticias restantes: ${noticiasRestantes}`);

    console.log('✅ Limpieza completada');

    // Cerrar conexión
    await sequelize.close();

  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Ejecutar el script
clearNews(); 