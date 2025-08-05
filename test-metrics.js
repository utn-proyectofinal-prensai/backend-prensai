const { News } = require("./models");
const { sequelize } = require("./models");

async function testMetrics() {
  try {
    console.log(" Probando endpoint de m�tricas...\n");
    await sequelize.authenticate();
    console.log(" Conexi�n a la base de datos establecida\n");

    // Obtener algunas noticias de prueba
    const noticias = await News.findAll({
      limit: 10,
      order: [["createdAt", "DESC"]]
    });

    if (noticias.length === 0) {
      console.log(" No hay noticias en la base de datos para probar");
      return;
    }

    console.log(` Probando con ${noticias.length} noticias:`);
    noticias.forEach((noticia, index) => {
      console.log(`  ${index + 1}. "${noticia.titulo}" - Soporte: ${noticia.soporte}`);
    });

    // Simular el c�lculo de m�tricas
    const newsIds = noticias.map(n => n.id);
    const soporteCounts = {};
    let totalNoticias = noticias.length;

    noticias.forEach(noticia => {
      const soporte = noticia.soporte || "Sin especificar";
      soporteCounts[soporte] = (soporteCounts[soporte] || 0) + 1;
    });

    // Calcular porcentajes
    const soporteMetrics = Object.entries(soporteCounts).map(([soporte, count]) => ({
      soporte,
      cantidad: count,
      porcentaje: Math.round((count / totalNoticias) * 100)
    }));

    // Ordenar por cantidad descendente
    soporteMetrics.sort((a, b) => b.cantidad - a.cantidad);

    console.log("\n M�tricas calculadas:");
    console.log(`  Total noticias: ${totalNoticias}`);
    console.log(`  Soportes �nicos: ${Object.keys(soporteCounts).length}`);
    console.log(`  Soporte m�s frecuente: ${soporteMetrics[0]?.soporte || "N/A"} (${soporteMetrics[0]?.porcentaje || 0}%)`);
    
    console.log("\n Distribuci�n por soporte:");
    soporteMetrics.forEach((item, index) => {
      const bar = "".repeat(Math.floor(item.porcentaje / 5));
      console.log(`  ${index + 1}. ${item.soporte}: ${item.cantidad} (${item.porcentaje}%) ${bar}`);
    });

    console.log("\n Prueba de m�tricas completada exitosamente");
    await sequelize.close();
  } catch (error) {
    console.error(" Error:", error.message);
    await sequelize.close();
  }
}

testMetrics();
