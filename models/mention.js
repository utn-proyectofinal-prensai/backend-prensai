'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Mention extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  Mention.init({
    nombre: DataTypes.STRING,
    activo: DataTypes.BOOLEAN,
    numeroMencion: DataTypes.INTEGER
  }, {
    sequelize,
    modelName: 'Mention',
  });
  return Mention;
};