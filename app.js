var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var cors = require('cors');
var helmet = require('helmet');

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');
var authRouter = require('./routes/auth');
var newsRouter = require('./routes/news');
var mentionsRouter = require('./routes/mentions');
var eventsRouter = require('./routes/events');

var app = express();

// Configurar CORS para permitir conexión con el frontend
app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:5175', 'http://localhost:5177'], // Múltiples puertos posibles
  credentials: true
}));

// Middleware de seguridad
app.use(helmet());

// Middleware de logging
app.use(logger('dev'));

// Middleware para parsear JSON y URL encoded
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

// Servir archivos estáticos
app.use(express.static(path.join(__dirname, 'public')));

// Rutas básicas
app.use('/', indexRouter);
app.use('/users', usersRouter);

// Rutas de la API de PrensAI
app.use('/api/auth', authRouter);
app.use('/api/news', newsRouter);
app.use('/api/mentions', mentionsRouter);
app.use('/api/events', eventsRouter);

// Ruta de prueba para verificar que el servidor funciona
app.get('/api/test', (req, res) => {
  res.json({ 
    message: 'PrensAI Backend funcionando correctamente!',
    timestamp: new Date().toISOString()
  });
});

module.exports = app;
