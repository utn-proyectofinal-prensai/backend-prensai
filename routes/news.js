const express = require('express');
const router = express.Router();
const multer = require('multer');
const xlsx = require('xlsx');
const { News, sequelize } = require('../models');
const { Op } = require('sequelize');

// Configurar multer para recibir archivos
const upload = multer({ 
  dest: 'uploads/',
  fileFilter: (req, file, cb) => {
    if (file.mimetype === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || 
        file.mimetype === 'application/vnd.ms-excel') {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten archivos Excel (.xlsx, .xls)'), false);
    }
  }
});

// POST /api/news/import - Importar noticias desde Excel
router.post('/import', upload.single('excel'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ 
        error: 'No se proporcionó archivo Excel' 
      });
    }

    console.log('Archivo recibido:', req.file);

    // Leer el archivo Excel
    const workbook = xlsx.readFile(req.file.path);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    
    // Convertir a JSON
    const jsonData = xlsx.utils.sheet_to_json(worksheet);

    console.log('Datos del Excel:', jsonData);

    // Procesar cada noticia
    const noticiasImportadas = [];
    const errores = [];

    for (let i = 0; i < jsonData.length; i++) {
      const row = jsonData[i];
      
      try {
        // Mapear campos del Excel a nuestro modelo (campos exactos del frontend)
        const noticiaData = {
          titulo: row.titulo || row.Titulo || row.TÍTULO || '',
          tipoPublicacion: row.tipoPublicacion || row.TipoPublicacion || row['Tipo Publicación'] || '',
          fecha: row.fecha ? new Date(row.fecha) : new Date(),
          soporte: row.soporte || row.Soporte || '',
          medio: row.medio || row.Medio || '',
          seccion: row.seccion || row.Seccion || row.SECCIÓN || '',
          autor: row.autor || row.Autor || row.AUTOR || '',
          conductor: row.conductor || row.Conductor || '',
          entrevistado: row.entrevistado || row.Entrevistado || '',
          tema: row.tema || row.Tema || row.TEMA || '',
          etiqueta1: row.etiqueta1 || row.Etiqueta1 || row.ETIQUETA1 || '',
          etiqueta2: row.etiqueta2 || row.Etiqueta2 || row.ETIQUETA2 || '',
          link: row.link || row.Link || row.LINK || '',
          alcance: row.alcance || row.Alcance || row.ALCANCE || '',
          cotizacion: row.cotizacion || row.Cotizacion || row.COTIZACION || '',
          tapa: row.tapa || row.Tapa || row.TAPA || '',
          valoracion: row.valoracion || row.Valoracion || row.VALORACION || '',
          ejeComunicacional: row.ejeComunicacional || row.EjeComunicacional || row['Eje Comunicacional'] || '',
          factorPolitico: row.factorPolitico || row.FactorPolitico || row['Factor Político'] || '',
          crisis: row.crisis || row.Crisis || row.CRISIS || '',
          gestion: row.gestion || row.Gestion || row.GESTIÓN || '',
          area: row.area || row.Area || row.AREA || '',
          mencion1: row.mencion1 || row.Mencion1 || row.MENCIÓN1 || '',
          mencion2: row.mencion2 || row.Mencion2 || row.MENCIÓN2 || '',
          mencion3: row.mencion3 || row.Mencion3 || row.MENCIÓN3 || '',
          mencion4: row.mencion4 || row.Mencion4 || row.MENCIÓN4 || '',
          mencion5: row.mencion5 || row.Mencion5 || row.MENCIÓN5 || '',
          status: 'processed' // Por defecto procesado
        };

        // Crear la noticia en la base de datos
        const noticia = await News.create(noticiaData);
        noticiasImportadas.push(noticia);

      } catch (error) {
        console.error(`Error procesando fila ${i + 1}:`, error);
        errores.push({
          fila: i + 1,
          error: error.message,
          datos: row
        });
      }
    }

    // Limpiar archivo temporal
    const fs = require('fs');
    fs.unlinkSync(req.file.path);

    res.json({
      message: 'Importación completada',
      totalProcesadas: jsonData.length,
      importadas: noticiasImportadas.length,
      errores: errores.length,
      detalles: {
        noticiasImportadas: noticiasImportadas.map(n => ({ id: n.id, titulo: n.titulo })),
        errores: errores
      }
    });

  } catch (error) {
    console.error('Error en importación:', error);
    res.status(500).json({ 
      error: 'Error al procesar el archivo Excel',
      details: error.message 
    });
  }
});

// GET /api/news - Listar noticias con filtros
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      search,
      status,
      tema,
      medio,
      fechaDesde,
      fechaHasta
    } = req.query;

    const offset = (page - 1) * limit;
    const whereClause = {};

    // Filtro por búsqueda
    if (search) {
      whereClause[Op.or] = [
        { titulo: { [Op.iLike]: `%${search}%` } },
        { medio: { [Op.iLike]: `%${search}%` } },
        { tema: { [Op.iLike]: `%${search}%` } }
      ];
    }

    // Filtro por estado
    if (status) {
      whereClause.status = status;
    }

    // Filtro por tema
    if (tema) {
      whereClause.tema = tema;
    }

    // Filtro por medio
    if (medio) {
      whereClause.medio = medio;
    }

    // Filtro por fecha
    if (fechaDesde || fechaHasta) {
      whereClause.fecha = {};
      if (fechaDesde) whereClause.fecha[Op.gte] = fechaDesde;
      if (fechaHasta) whereClause.fecha[Op.lte] = fechaHasta;
    }

    const { count, rows } = await News.findAndCountAll({
      where: whereClause,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['createdAt', 'DESC']]
    });

    res.json({
      noticias: rows,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit)
      }
    });

  } catch (error) {
    console.error('Error obteniendo noticias:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor' 
    });
  }
});

// GET /api/news/stats - Estadísticas del dashboard
router.get('/stats', async (req, res) => {
  try {
    const totalNoticias = await News.count();
    
    const noticiasHoy = await News.count({
      where: {
        fecha: {
          [Op.gte]: new Date().setHours(0, 0, 0, 0)
        }
      }
    });

    const noticiasEstaSemana = await News.count({
      where: {
        fecha: {
          [Op.gte]: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
        }
      }
    });

    const noticiasEsteMes = await News.count({
      where: {
        fecha: {
          [Op.gte]: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
        }
      }
    });

    // Estadísticas por estado
    const noticiasPorEstado = await News.findAll({
      attributes: ['status', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['status']
    });

    // Estadísticas por tema
    const noticiasPorTema = await News.findAll({
      attributes: ['tema', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['tema'],
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']],
      limit: 10
    });

    // Estadísticas por medio
    const noticiasPorMedio = await News.findAll({
      attributes: ['medio', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['medio'],
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']],
      limit: 10
    });

    // Últimas noticias
    const ultimasNoticias = await News.findAll({
      order: [['createdAt', 'DESC']],
      limit: 5
    });

    res.json({
      totalNoticias,
      noticiasHoy,
      noticiasEstaSemana,
      noticiasEsteMes,
      noticiasPorTema: noticiasPorTema.map(item => ({
        tema: item.tema,
        count: parseInt(item.dataValues.count)
      })),
      noticiasPorMedio: noticiasPorMedio.map(item => ({
        medio: item.medio,
        count: parseInt(item.dataValues.count)
      }))
    });

  } catch (error) {
    console.error('Error obteniendo estadísticas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// GET /api/news/:id - Obtener noticia específica
router.get('/:id', async (req, res) => {
  try {
    const noticia = await News.findByPk(req.params.id);
    
    if (!noticia) {
      return res.status(404).json({ error: 'Noticia no encontrada' });
    }

    res.json(noticia);

  } catch (error) {
    console.error('Error obteniendo noticia:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// POST /api/news/metrics - Calcular métricas de noticias seleccionadas
router.post('/metrics', async (req, res) => {
  try {
    const { newsIds } = req.body;
    
    if (!newsIds || !Array.isArray(newsIds) || newsIds.length === 0) {
      return res.status(400).json({ error: 'Se requieren IDs de noticias válidos' });
    }

    // Obtener las noticias seleccionadas
    const selectedNews = await News.findAll({
      where: {
        id: newsIds
      }
    });

    if (selectedNews.length === 0) {
      return res.status(404).json({ error: 'No se encontraron noticias con los IDs proporcionados' });
    }

    // Calcular métricas por soporte
    const soporteCounts = {};
    let totalNoticias = selectedNews.length;

    selectedNews.forEach(noticia => {
      const soporte = noticia.soporte || 'Sin especificar';
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

    // Calcular métricas adicionales básicas
    const metricas = {
      totalNoticias,
      soporte: soporteMetrics,
      resumen: {
        soportesUnicos: Object.keys(soporteCounts).length,
        soporteMasFrecuente: soporteMetrics[0]?.soporte || 'N/A',
        porcentajeSoporteMasFrecuente: soporteMetrics[0]?.porcentaje || 0
      }
    };

    res.json({
      message: 'Métricas calculadas correctamente',
      metricas
    });

  } catch (error) {
    console.error('Error calculando métricas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router; 