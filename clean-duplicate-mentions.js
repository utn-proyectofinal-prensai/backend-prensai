const { ActiveMention } = require('./models');
const { sequelize } = require('./models');

async function cleanDuplicateMentions() {
  try {
    console.log('🧹 Limpiando menciones duplicadas...\n');
    await sequelize.authenticate();
    console.log('✅ Conexión a la base de datos establecida\n');
    
    // Obtener todas las menciones
    const allMentions = await ActiveMention.findAll({
      order: [['name', 'ASC'], ['createdAt', 'ASC']]
    });
    
    console.log(`📊 Total de menciones encontradas: ${allMentions.length}`);
    
    // Agrupar por nombre (case insensitive)
    const groupedMentions = new Map();
    allMentions.forEach(mention => {
      const key = mention.name.toLowerCase();
      if (!groupedMentions.has(key)) {
        groupedMentions.set(key, []);
      }
      groupedMentions.get(key).push(mention);
    });
    
    let totalDeleted = 0;
    
    // Procesar cada grupo
    for (const [name, mentions] of groupedMentions) {
      if (mentions.length > 1) {
        console.log(`\n🔍 Menciones duplicadas encontradas para "${mentions[0].name}":`);
        mentions.forEach((mention, index) => {
          console.log(`  ${index + 1}. ID: ${mention.id}, Activa: ${mention.isActive}, Posición: ${mention.position}, Creada: ${mention.createdAt}`);
        });
        
        // Mantener la primera (más antigua) y eliminar las demás
        const [keepMention, ...duplicates] = mentions;
        console.log(`✅ Manteniendo ID: ${keepMention.id} (más antigua)`);
        
        for (const duplicate of duplicates) {
          console.log(`🗑️ Eliminando ID: ${duplicate.id}`);
          await duplicate.destroy();
          totalDeleted++;
        }
      }
    }
    
    if (totalDeleted === 0) {
      console.log('\n✅ No se encontraron menciones duplicadas');
    } else {
      console.log(`\n✅ Limpieza completada. Se eliminaron ${totalDeleted} menciones duplicadas`);
    }
    
    // Mostrar estado final
    const finalMentions = await ActiveMention.findAll({
      order: [['name', 'ASC']]
    });
    console.log(`\n📊 Estado final: ${finalMentions.length} menciones únicas`);
    finalMentions.forEach(mention => {
      console.log(`  • "${mention.name}" - Activa: ${mention.isActive}, Posición: ${mention.position}`);
    });
    
    await sequelize.close();
  } catch (error) {
    console.error('❌ Error:', error.message);
    await sequelize.close();
  }
}

cleanDuplicateMentions(); 