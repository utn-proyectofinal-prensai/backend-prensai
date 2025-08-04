const express = require('express');
const router = express.Router();
const { ActiveMention } = require('../models');

// GET /api/mentions/active - Obtener menciones activas
router.get('/active', async (req, res) => {
  try {
    const activeMentions = await ActiveMention.findAll({
      where: { isActive: true },
      order: [['position', 'ASC']],
      attributes: ['position', 'name']
    });

    res.json({
      activeMentions: activeMentions.map(mention => ({
        position: mention.position,
        name: mention.name
      }))
    });
  } catch (error) {
    console.error('Error obteniendo menciones activas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// PUT /api/mentions/active - Actualizar menciones activas
router.put('/active', async (req, res) => {
  try {
    const { mentions } = req.body;

    if (!mentions || !Array.isArray(mentions)) {
      return res.status(400).json({ error: 'Formato inválido. Se requiere array de menciones' });
    }

    if (mentions.length > 5) {
      return res.status(400).json({ error: 'Máximo 5 menciones activas permitidas' });
    }

    // Validar posiciones únicas
    const positions = mentions.map(m => m.position);
    const uniquePositions = [...new Set(positions)];
    if (positions.length !== uniquePositions.length) {
      return res.status(400).json({ error: 'Posiciones duplicadas no permitidas' });
    }

    // Validar rango de posiciones
    for (const mention of mentions) {
      if (mention.position < 1 || mention.position > 5) {
        return res.status(400).json({ error: 'Posiciones deben estar entre 1 y 5' });
      }
      if (!mention.name || typeof mention.name !== 'string') {
        return res.status(400).json({ error: 'Nombre de mención requerido' });
      }
    }

    // Obtener todas las menciones existentes
    const existingMentions = await ActiveMention.findAll();
    
    // Crear un mapa de menciones existentes por nombre para búsqueda rápida
    const existingMentionsMap = new Map();
    existingMentions.forEach(mention => {
      existingMentionsMap.set(mention.name.toLowerCase(), mention);
    });

    // Obtener nombres de menciones que queremos activar
    const targetMentionNames = mentions.map(m => m.name.toLowerCase());
    
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
    for (const mention of mentions) {
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

    res.json({
      message: 'Menciones activas actualizadas correctamente',
      activeMentions: mentions
    });
  } catch (error) {
    console.error('Error actualizando menciones activas:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// GET /api/mentions/all - Obtener todas las menciones (para el frontend)
router.get('/all', async (req, res) => {
  try {
    const allMentions = await ActiveMention.findAll({
      order: [['position', 'ASC']],
      attributes: ['id', 'position', 'name', 'isActive', 'createdAt']
    });

    res.json({
      mentions: allMentions
    });
  } catch (error) {
    console.error('Error obteniendo todas las menciones:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// POST /api/mentions - Crear una nueva mención
router.post('/', async (req, res) => {
  try {
    const { name } = req.body;

    if (!name || typeof name !== 'string') {
      return res.status(400).json({ error: 'Nombre de mención requerido' });
    }

    // Crear mención como inactiva (sin posición)
    const nuevaMencion = await ActiveMention.create({
      name: name.trim(),
      position: null, // Sin posición = inactiva
      isActive: false
    });

    res.status(201).json({
      message: 'Mención creada correctamente',
      mention: {
        id: nuevaMencion.id,
        name: nuevaMencion.name,
        isActive: nuevaMencion.isActive,
        position: nuevaMencion.position
      }
    });
  } catch (error) {
    console.error('Error creando mención:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// PUT /api/mentions/:id - Actualizar una mención
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name } = req.body;

    if (!name || typeof name !== 'string') {
      return res.status(400).json({ error: 'Nombre de mención requerido' });
    }

    const mencion = await ActiveMention.findByPk(id);
    if (!mencion) {
      return res.status(404).json({ error: 'Mención no encontrada' });
    }

    await mencion.update({
      name: name.trim()
    });

    res.json({
      message: 'Mención actualizada correctamente',
      mention: {
        id: mencion.id,
        name: mencion.name,
        isActive: mencion.isActive,
        position: mencion.position
      }
    });
  } catch (error) {
    console.error('Error actualizando mención:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// DELETE /api/mentions/:id - Eliminar una mención
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const mencion = await ActiveMention.findByPk(id);
    if (!mencion) {
      return res.status(404).json({ error: 'Mención no encontrada' });
    }

    await mencion.destroy();

    res.json({
      message: 'Mención eliminada correctamente'
    });
  } catch (error) {
    console.error('Error eliminando mención:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router; 