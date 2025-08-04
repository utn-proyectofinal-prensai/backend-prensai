const { ActiveMention } = require('./models');
const { sequelize } = require('./models');

async function testDragDrop() {
  try {
    console.log('🧪 Probando drag & drop...\n');
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida\n');
    
    // Estado inicial: activar algunas menciones
    console.log('📊 Estado inicial:');
    await ActiveMention.update(
      { isActive: true, position: 1 },
      { where: { name: 'Juan Pérez' } }
    );
    await ActiveMention.update(
      { isActive: true, position: 2 },
      { where: { name: 'María García' } }
    );
    
    const initialMentions = await ActiveMention.findAll({
      order: [['name', 'ASC']]
    });
    initialMentions.forEach(mention => {
      console.log(`  • "${mention.name}" - Activa: ${mention.isActive}, Posición: ${mention.position}`);
    });
    
    // Simular drag & drop: agregar "Carlos López" a posición 3
    console.log('\n🔄 Simulando drag & drop: agregar "Carlos López" a posición 3');
    
    const newActiveMentions = [
      { position: 1, name: 'Juan Pérez' },
      { position: 2, name: 'María García' },
      { position: 3, name: 'Carlos López' }
    ];
    
    // Obtener todas las menciones existentes
    const existingMentions = await ActiveMention.findAll();
    const existingMentionsMap = new Map();
    existingMentions.forEach(mention => {
      existingMentionsMap.set(mention.name.toLowerCase(), mention);
    });

    // Obtener nombres de menciones que queremos activar
    const targetMentionNames = newActiveMentions.map(m => m.name.toLowerCase());
    
    // Obtener menciones actualmente activas
    const currentlyActiveMentions = await ActiveMention.findAll({
      where: { isActive: true }
    });
    
    // Encontrar menciones que están activas pero NO están en la nueva lista
    const mentionsToDeactivate = currentlyActiveMentions.filter(mention => 
      !targetMentionNames.includes(mention.name.toLowerCase())
    );
    
    // Desactivar solo las menciones que ya no están en la lista
    if (mentionsToDeactivate.length > 0) {
      const namesToDeactivate = mentionsToDeactivate.map(m => m.name);
      await ActiveMention.update(
        { isActive: false, position: null },
        { 
          where: { 
            name: {
              [require('sequelize').Op.in]: namesToDeactivate
            }
          } 
        }
      );
      console.log(`Desactivadas: ${namesToDeactivate.join(', ')}`);
    }

    // Procesar cada mención activa
    for (const mention of newActiveMentions) {
      const existingMention = existingMentionsMap.get(mention.name.toLowerCase());
      
      if (existingMention) {
        // Actualizar mención existente
        await existingMention.update({
          isActive: true,
          position: mention.position
        });
      } else {
        // Crear nueva mención solo si no existe
        await ActiveMention.create({
          name: mention.name,
          position: mention.position,
          isActive: true
        });
      }
    }
    
    // Estado final
    console.log('\n📊 Estado final:');
    const finalMentions = await ActiveMention.findAll({
      order: [['name', 'ASC']]
    });
    finalMentions.forEach(mention => {
      console.log(`  • "${mention.name}" - Activa: ${mention.isActive}, Posición: ${mention.position}`);
    });
    
    // Verificar que Juan Pérez y María García mantuvieron sus posiciones
    const juanPerez = finalMentions.find(m => m.name === 'Juan Pérez');
    const mariaGarcia = finalMentions.find(m => m.name === 'María García');
    
    console.log('\n✅ Verificación:');
    console.log(`  • Juan Pérez mantuvo posición: ${juanPerez?.position === 1 ? 'SÍ' : 'NO'}`);
    console.log(`  • María García mantuvo posición: ${mariaGarcia?.position === 2 ? 'SÍ' : 'NO'}`);
    
    await sequelize.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
    await sequelize.close();
  }
}

testDragDrop(); 