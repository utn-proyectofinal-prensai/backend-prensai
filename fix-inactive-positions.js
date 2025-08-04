const { ActiveMention } = require('./models');
const { sequelize } = require('./models');

async function fixInactivePositions() {
  try {
    console.log('🔧 Arreglando posiciones de menciones inactivas...\n');
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida\n');
    
    // Obtener todas las menciones
    const allMentions = await ActiveMention.findAll({
      order: [['name', 'ASC']]
    });
    
    console.log('📊 Estado actual:');
    allMentions.forEach(mention => {
      console.log(`  • "${mention.name}" - Activa: ${mention.isActive}, Posición: ${mention.position}`);
    });
    
    // Encontrar menciones inactivas con posición asignada
    const inactiveWithPosition = allMentions.filter(mention => 
      !mention.isActive && mention.position !== null
    );
    
    if (inactiveWithPosition.length === 0) {
      console.log('\n✅ No hay menciones inactivas con posición asignada');
    } else {
      console.log(`\n🔍 Encontradas ${inactiveWithPosition.length} menciones inactivas con posición asignada:`);
      inactiveWithPosition.forEach(mention => {
        console.log(`  • "${mention.name}" - Posición actual: ${mention.position}`);
      });
      
      // Limpiar posiciones de menciones inactivas
      await ActiveMention.update(
        { position: null },
        { where: { isActive: false } }
      );
      
      console.log('\n✅ Posiciones limpiadas para menciones inactivas');
    }
    
    // Mostrar estado final
    const finalMentions = await ActiveMention.findAll({
      order: [['name', 'ASC']]
    });
    
    console.log('\n📊 Estado final:');
    finalMentions.forEach(mention => {
      console.log(`  • "${mention.name}" - Activa: ${mention.isActive}, Posición: ${mention.position}`);
    });
    
    await sequelize.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
    await sequelize.close();
  }
}

fixInactivePositions(); 