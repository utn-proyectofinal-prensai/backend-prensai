const { Sequelize } = require('sequelize');
const config = require('./config/config.json');

// Configurar conexión a la base de datos
const sequelize = new Sequelize(config.development);

// Importar el modelo News
const News = require('./models/news');

async function insertTestData() {
  try {
    // Conectar a la base de datos
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida.');

    // Sincronizar el modelo
    await sequelize.sync();
    console.log('✅ Modelo sincronizado.');

    // Datos de prueba con diferentes valoraciones
    const testNews = [
      {
        titulo: 'Noticia de prueba 1 - Negativa',
        contenido: 'Esta es una noticia de prueba con valoración negativa',
        fecha: new Date('2024-01-15'),
        soporte: 'Digital',
        medio: 'El País',
        tema: 'Política',
        valoracion: 'Negativa',
        ejeComunicacional: 'Transparencia',
        factorPolitico: 'Alto',
        crisis: 'Sí',
        gestion: 'Pública',
        area: 'Administración',
        menciones: 'Presidente, Ministro',
        mencion1: 'Presidente',
        mencion2: 'Ministro',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 2 - Positiva',
        contenido: 'Esta es una noticia de prueba con valoración positiva',
        fecha: new Date('2024-01-16'),
        soporte: 'Impreso',
        medio: 'ABC',
        tema: 'Economía',
        valoracion: 'Positiva',
        ejeComunicacional: 'Desarrollo',
        factorPolitico: 'Medio',
        crisis: 'No',
        gestion: 'Privada',
        area: 'Finanzas',
        menciones: 'Empresario, Inversor',
        mencion1: 'Empresario',
        mencion2: 'Inversor',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 3 - Neutra',
        contenido: 'Esta es una noticia de prueba con valoración neutra',
        fecha: new Date('2024-01-17'),
        soporte: 'Digital',
        medio: 'El Mundo',
        tema: 'Sociedad',
        valoracion: 'Neutra',
        ejeComunicacional: 'Información',
        factorPolitico: 'Bajo',
        crisis: 'Baja',
        gestion: 'Mixta',
        area: 'Social',
        menciones: 'Ciudadano, Vecino',
        mencion1: 'Ciudadano',
        mencion2: 'Vecino',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 4 - Negativa',
        contenido: 'Esta es otra noticia de prueba con valoración negativa',
        fecha: new Date('2024-01-18'),
        soporte: 'Digital',
        medio: 'La Vanguardia',
        tema: 'Política',
        valoracion: 'Negativa',
        ejeComunicacional: 'Crítica',
        factorPolitico: 'Alto',
        crisis: 'Alta',
        gestion: 'Pública',
        area: 'Administración',
        menciones: 'Opositor, Crítico',
        mencion1: 'Opositor',
        mencion2: 'Crítico',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 5 - Negativa',
        contenido: 'Esta es una tercera noticia de prueba con valoración negativa',
        fecha: new Date('2024-01-19'),
        soporte: 'Impreso',
        medio: 'El País',
        tema: 'Economía',
        valoracion: 'Negativa',
        ejeComunicacional: 'Análisis',
        factorPolitico: 'Medio',
        crisis: 'Moderada',
        gestion: 'Privada',
        area: 'Finanzas',
        menciones: 'Analista, Experto',
        mencion1: 'Analista',
        mencion2: 'Experto',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 6 - Negativa',
        contenido: 'Esta es una cuarta noticia de prueba con valoración negativa',
        fecha: new Date('2024-01-20'),
        soporte: 'Digital',
        medio: 'ABC',
        tema: 'Sociedad',
        valoracion: 'Negativa',
        ejeComunicacional: 'Denuncia',
        factorPolitico: 'Bajo',
        crisis: 'Sí',
        gestion: 'Pública',
        area: 'Social',
        menciones: 'Denunciante, Testigo',
        mencion1: 'Denunciante',
        mencion2: 'Testigo',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 7 - Negativa',
        contenido: 'Esta es una quinta noticia de prueba con valoración negativa',
        fecha: new Date('2024-01-21'),
        soporte: 'Impreso',
        medio: 'El Mundo',
        tema: 'Política',
        valoracion: 'Negativa',
        ejeComunicacional: 'Oposición',
        factorPolitico: 'Alto',
        crisis: 'Alta',
        gestion: 'Pública',
        area: 'Administración',
        menciones: 'Opositor, Líder',
        mencion1: 'Opositor',
        mencion2: 'Líder',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 8 - Positiva',
        contenido: 'Esta es otra noticia de prueba con valoración positiva',
        fecha: new Date('2024-01-22'),
        soporte: 'Digital',
        medio: 'La Vanguardia',
        tema: 'Economía',
        valoracion: 'Positiva',
        ejeComunicacional: 'Logro',
        factorPolitico: 'Medio',
        crisis: 'No',
        gestion: 'Privada',
        area: 'Finanzas',
        menciones: 'Empresario, Inversor',
        mencion1: 'Empresario',
        mencion2: 'Inversor',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 9 - Neutra',
        contenido: 'Esta es otra noticia de prueba con valoración neutra',
        fecha: new Date('2024-01-23'),
        soporte: 'Impreso',
        medio: 'El País',
        tema: 'Sociedad',
        valoracion: 'Neutra',
        ejeComunicacional: 'Información',
        factorPolitico: 'Bajo',
        crisis: 'Baja',
        gestion: 'Mixta',
        area: 'Social',
        menciones: 'Ciudadano, Vecino',
        mencion1: 'Ciudadano',
        mencion2: 'Vecino',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      },
      {
        titulo: 'Noticia de prueba 10 - No especificada',
        contenido: 'Esta es una noticia de prueba sin valoración especificada',
        fecha: new Date('2024-01-24'),
        soporte: 'Digital',
        medio: 'ABC',
        tema: 'Política',
        valoracion: '',
        ejeComunicacional: 'Información',
        factorPolitico: 'Medio',
        crisis: 'Moderada',
        gestion: 'Pública',
        area: 'Administración',
        menciones: 'Funcionario, Ciudadano',
        mencion1: 'Funcionario',
        mencion2: 'Ciudadano',
        mencion3: '',
        mencion4: '',
        mencion5: ''
      }
    ];

    // Insertar los datos de prueba
    console.log('📝 Insertando datos de prueba...');
    for (const newsData of testNews) {
      await News.create(newsData);
    }

    console.log(`✅ Se insertaron ${testNews.length} noticias de prueba exitosamente.`);
    console.log('\n📊 Resumen de datos insertados:');
    console.log('  - 5 noticias con valoración "Negativa"');
    console.log('  - 2 noticias con valoración "Positiva"');
    console.log('  - 2 noticias con valoración "Neutra"');
    console.log('  - 1 noticia sin valoración especificada');
    console.log('\n🎯 Con 5 valoraciones negativas, el tema debería ser considerado "CRÍTICO"');

  } catch (error) {
    console.error('❌ Error al insertar datos de prueba:', error);
  } finally {
    // Cerrar la conexión
    await sequelize.close();
    console.log('🔌 Conexión a la base de datos cerrada.');
  }
}

// Ejecutar la función
insertTestData();
