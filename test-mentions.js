const { ActiveMention } = require('./models');
const { sequelize } = require('./models');

async function testMentions() {
  try {
    console.log('🧪 Probando sistema de menciones activas...\n');
    
    // 1. Verificar conexión
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida\n');
    
    // 2. Verificar estado inicial
    console.log('📊 Estado inicial de la tabla ActiveMentions:');
    const totalMentions = await ActiveMention.count();
    console.log(`   Total de menciones: ${totalMentions}`);
    
    const activeMentions = await ActiveMention.findAll({
      where: { isActive: true },
      order: [['position', 'ASC']]
    });
    console.log(`   Menciones activas: ${activeMentions.length}`);
    
    if (activeMentions.length > 0) {
      console.log('   Menciones activas actuales:');
      activeMentions.forEach(mention => {
        console.log(`     Posición ${mention.position}: ${mention.name}`);
      });
    }
    console.log('');
    
    // 3. Agregar menciones de prueba
    console.log('➕ Agregando menciones de prueba...');
    const testMentions = [
      { position: 1, name: 'Juan Pérez', isActive: true },
      { position: 2, name: 'María García', isActive: true },
      { position: 3, name: 'Carlos López', isActive: true }
    ];
    
    // Desactivar todas las menciones actuales
    await ActiveMention.update(
      { isActive: false },
      { where: { isActive: true } }
    );
    
    // Insertar las nuevas menciones
    await ActiveMention.bulkCreate(testMentions);
    console.log('✅ Menciones de prueba agregadas\n');
    
    // 4. Verificar estado final
    console.log('📊 Estado final de la tabla ActiveMentions:');
    const finalTotal = await ActiveMention.count();
    console.log(`   Total de menciones: ${finalTotal}`);
    
    const finalActive = await ActiveMention.findAll({
      where: { isActive: true },
      order: [['position', 'ASC']]
    });
    console.log(`   Menciones activas: ${finalActive.length}`);
    
    console.log('   Menciones activas finales:');
    finalActive.forEach(mention => {
      console.log(`     Posición ${mention.position}: ${mention.name}`);
    });
    
    console.log('\n✅ Prueba completada exitosamente');
    await sequelize.close();
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    await sequelize.close();
  }
}

testMentions(); 