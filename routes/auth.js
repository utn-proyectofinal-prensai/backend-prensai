const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { User } = require('../models');

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Buscar usuario en la base de datos
    const user = await User.findOne({ where: { username } });

    if (!user) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas' 
      });
    }

    // Verificar contraseña
    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas' 
      });
    }

    // Generar token JWT
    const token = jwt.sign(
      { 
        id: user.id, 
        username: user.username,
        role: user.role 
      },
      process.env.JWT_SECRET || 'prensai_jwt_secret_key_2024',
      { expiresIn: '24h' }
    );

    res.json({
      message: 'Login exitoso',
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      }
    });

  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ 
      error: 'Error interno del servidor' 
    });
  }
});

// POST /api/auth/logout
router.post('/logout', (req, res) => {
  // En JWT, el logout se maneja del lado del cliente
  // eliminando el token del localStorage
  res.json({ 
    message: 'Logout exitoso' 
  });
});

// GET /api/auth/me - Verificar token actual
router.get('/me', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({ 
        error: 'Token no proporcionado' 
      });
    }

    const decoded = jwt.verify(
      token, 
      process.env.JWT_SECRET || 'prensai_jwt_secret_key_2024'
    );

    const user = await User.findByPk(decoded.id);

    if (!user) {
      return res.status(401).json({ 
        error: 'Usuario no encontrado' 
      });
    }

    res.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role
      }
    });

  } catch (error) {
    console.error('Error verificando token:', error);
    res.status(401).json({ 
      error: 'Token inválido' 
    });
  }
});

module.exports = router; 