const express = require('express');
const router = express.Router();
const { Event } = require('../models');

// GET /api/events - Obtener todos los eventos
router.get('/', async (req, res) => {
  try {
    const events = await Event.findAll({
      order: [['name', 'ASC']],
      attributes: ['id', 'name', 'description', 'color', 'isActive', 'tags', 'createdAt']
    });

    res.json({
      events: events
    });
  } catch (error) {
    console.error('Error obteniendo eventos:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// GET /api/events/active - Obtener solo eventos activos (para el módulo de IA)
router.get('/active', async (req, res) => {
  try {
    const activeEvents = await Event.findAll({
      where: { isActive: true },
      order: [['name', 'ASC']],
      attributes: ['id', 'name', 'description', 'color', 'tags']
    });

    res.json({
      activeEvents: activeEvents
    });
  } catch (error) {
    console.error('Error obteniendo eventos activos:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// POST /api/events - Crear un nuevo evento
router.post('/', async (req, res) => {
  try {
    const { name, description, color, tags } = req.body;

    if (!name || typeof name !== 'string') {
      return res.status(400).json({ error: 'Nombre de evento requerido' });
    }

    // Verificar si ya existe un evento con ese nombre
    const existingEvent = await Event.findOne({
      where: { name: name.trim() }
    });

    if (existingEvent) {
      return res.status(400).json({ error: 'Ya existe un evento con ese nombre' });
    }

    // Crear el evento
    const newEvent = await Event.create({
      name: name.trim(),
      description: description?.trim() || '',
      color: color || '#3B82F6',
      isActive: true,
      tags: tags || []
    });

    res.status(201).json({
      message: 'Evento creado correctamente',
      event: {
        id: newEvent.id,
        name: newEvent.name,
        description: newEvent.description,
        color: newEvent.color,
        isActive: newEvent.isActive,
        tags: newEvent.tags
      }
    });
  } catch (error) {
    console.error('Error creando evento:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// PUT /api/events/:id - Actualizar un evento
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, color, isActive, tags } = req.body;

    if (!name || typeof name !== 'string') {
      return res.status(400).json({ error: 'Nombre de evento requerido' });
    }

    const event = await Event.findByPk(id);
    if (!event) {
      return res.status(404).json({ error: 'Evento no encontrado' });
    }

    // Verificar si el nuevo nombre ya existe en otro evento
    const existingEvent = await Event.findOne({
      where: { 
        name: name.trim(),
        id: { [require('sequelize').Op.ne]: id }
      }
    });

    if (existingEvent) {
      return res.status(400).json({ error: 'Ya existe otro evento con ese nombre' });
    }

    await event.update({
      name: name.trim(),
      description: description?.trim() || '',
      color: color || event.color,
      isActive: isActive !== undefined ? isActive : event.isActive,
      tags: tags || event.tags
    });

    res.json({
      message: 'Evento actualizado correctamente',
      event: {
        id: event.id,
        name: event.name,
        description: event.description,
        color: event.color,
        isActive: event.isActive,
        tags: event.tags
      }
    });
  } catch (error) {
    console.error('Error actualizando evento:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// DELETE /api/events/:id - Eliminar un evento
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const event = await Event.findByPk(id);
    if (!event) {
      return res.status(404).json({ error: 'Evento no encontrado' });
    }

    await event.destroy();

    res.json({
      message: 'Evento eliminado correctamente'
    });
  } catch (error) {
    console.error('Error eliminando evento:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router; 