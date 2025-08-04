const { Event } = require('./models');
const { sequelize } = require('./models');

async function testEvents() {
  try {
    console.log('🧪 Probando API de eventos...\n');
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida\n');
    
    // Crear algunos eventos de prueba
    console.log('📝 Creando eventos de prueba...');
    
    const eventosPrueba = [
      {
        name: 'Elecciones 2024',
        description: 'Proceso electoral nacional',
        color: '#3B82F6',
        isActive: true,
        tags: ['política', 'nacional', 'elecciones']
      },
      {
        name: 'Economía',
        description: 'Noticias económicas y financieras',
        color: '#10B981',
        isActive: true,
        tags: ['finanzas', 'mercado']
      },
      {
        name: 'Tecnología',
        description: 'Innovaciones tecnológicas',
        color: '#F59E0B',
        isActive: true,
        tags: ['innovación', 'digital', 'IA']
      }
    ];
    
    for (const evento of eventosPrueba) {
      try {
        await Event.create(evento);
        console.log(`✅ Creado: "${evento.name}"`);
      } catch (error) {
        if (error.name === 'SequelizeUniqueConstraintError') {
          console.log(`⚠️ Ya existe: "${evento.name}"`);
        } else {
          console.error(`❌ Error creando "${evento.name}":`, error.message);
        }
      }
    }
    
    // Mostrar todos los eventos
    console.log('\n📊 Todos los eventos:');
    const allEvents = await Event.findAll({
      order: [['name', 'ASC']]
    });
    
    allEvents.forEach(event => {
      console.log(`  • "${event.name}" - Activo: ${event.isActive}, Color: ${event.color}, Tags: [${event.tags.join(', ')}]`);
    });
    
    // Mostrar solo eventos activos (para el módulo de IA)
    console.log('\n🎯 Eventos activos (para módulo de IA):');
    const activeEvents = await Event.findAll({
      where: { isActive: true },
      order: [['name', 'ASC']]
    });
    
    activeEvents.forEach(event => {
      console.log(`  • "${event.name}" - Color: ${event.color}, Tags: [${event.tags.join(', ')}]`);
    });
    
    console.log(`\n✅ Total eventos: ${allEvents.length}`);
    console.log(`✅ Eventos activos: ${activeEvents.length}`);
    
    await sequelize.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
    await sequelize.close();
  }
}

testEvents(); 