'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class News extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  News.init({
    titulo: DataTypes.STRING,
    tipoPublicacion: DataTypes.STRING,
    fecha: DataTypes.DATE,
    soporte: DataTypes.STRING,
    medio: DataTypes.STRING,
    seccion: DataTypes.STRING,
    autor: DataTypes.STRING,
    conductor: DataTypes.STRING,
    entrevistado: DataTypes.STRING,
    tema: DataTypes.STRING,
    etiqueta1: DataTypes.STRING,
    etiqueta2: DataTypes.STRING,
    link: DataTypes.STRING,
    alcance: DataTypes.STRING,
    cotizacion: DataTypes.STRING,
    tapa: DataTypes.STRING,
    valoracion: DataTypes.STRING,
    ejeComunicacional: DataTypes.STRING,
    factorPolitico: DataTypes.STRING,
    crisis: DataTypes.STRING,
    gestion: DataTypes.STRING,
    area: DataTypes.STRING,
    mencion1: DataTypes.STRING,
    mencion2: DataTypes.STRING,
    mencion3: DataTypes.STRING,
    mencion4: DataTypes.STRING,
    mencion5: DataTypes.STRING,
    status: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'News',
  });
  return News;
};