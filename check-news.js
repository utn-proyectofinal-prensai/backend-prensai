const { News } = require('./models');

async function checkNews() {
  try {
    console.log('🔍 Verificando noticias en la base de datos...\n');

    // Conectar a la base de datos
    const { sequelize } = require('./models');
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida\n');

    // Contar total de noticias
    const totalNoticias = await News.count();
    console.log(`📊 Total de noticias en la base de datos: ${totalNoticias}`);

    if (totalNoticias === 0) {
      console.log('❌ No hay noticias en la base de datos');
      return;
    }

    // Obtener las últimas 5 noticias
    const ultimasNoticias = await News.findAll({
      order: [['createdAt', 'DESC']],
      limit: 5
    });

    console.log('\n📰 ÚLTIMAS NOTICIAS IMPORTADAS:');
    console.log('================================');
    ultimasNoticias.forEach((noticia, index) => {
      console.log(`${index + 1}. ID: ${noticia.id}`);
      console.log(`   Título: ${noticia.titulo}`);
      console.log(`   Medio: ${noticia.medio}`);
      console.log(`   Tema: ${noticia.tema}`);
      console.log(`   Fecha: ${noticia.fecha}`);
      console.log(`   Status: ${noticia.status}`);
      console.log('');
    });

    // Estadísticas por tema
    const temas = await News.findAll({
      attributes: ['tema', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['tema'],
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']]
    });

    console.log('📈 ESTADÍSTICAS POR TEMA:');
    console.log('=========================');
    temas.forEach(tema => {
      console.log(`• ${tema.tema}: ${tema.dataValues.count} noticias`);
    });

    // Estadísticas por medio
    const medios = await News.findAll({
      attributes: ['medio', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['medio'],
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']]
    });

    console.log('\n📺 ESTADÍSTICAS POR MEDIO:');
    console.log('===========================');
    medios.forEach(medio => {
      console.log(`• ${medio.medio}: ${medio.dataValues.count} noticias`);
    });

    // Verificar campos específicos
    console.log('\n🔍 VERIFICACIÓN DE CAMPOS:');
    console.log('==========================');
    const primeraNoticia = await News.findOne();
    if (primeraNoticia) {
      console.log('Campos disponibles en la primera noticia:');
      Object.keys(primeraNoticia.dataValues).forEach(campo => {
        if (campo !== 'id' && campo !== 'createdAt' && campo !== 'updatedAt') {
          console.log(`• ${campo}: ${primeraNoticia[campo] || '(vacío)'}`);
        }
      });
    }

    console.log('\n✅ Verificación completada');

    // Cerrar conexión
    await sequelize.close();

  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Ejecutar el script
checkNews(); 