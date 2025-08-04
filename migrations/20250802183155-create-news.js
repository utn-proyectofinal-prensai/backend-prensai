'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('News', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      titulo: {
        type: Sequelize.STRING
      },
      tipoPublicacion: {
        type: Sequelize.STRING
      },
      fecha: {
        type: Sequelize.DATE
      },
      soporte: {
        type: Sequelize.STRING
      },
      medio: {
        type: Sequelize.STRING
      },
      seccion: {
        type: Sequelize.STRING
      },
      autor: {
        type: Sequelize.STRING
      },
      conductor: {
        type: Sequelize.STRING
      },
      entrevistado: {
        type: Sequelize.STRING
      },
      tema: {
        type: Sequelize.STRING
      },
      etiqueta1: {
        type: Sequelize.STRING
      },
      etiqueta2: {
        type: Sequelize.STRING
      },
      link: {
        type: Sequelize.STRING
      },
      alcance: {
        type: Sequelize.STRING
      },
      cotizacion: {
        type: Sequelize.STRING
      },
      tapa: {
        type: Sequelize.STRING
      },
      valoracion: {
        type: Sequelize.STRING
      },
      ejeComunicacional: {
        type: Sequelize.STRING
      },
      factorPolitico: {
        type: Sequelize.STRING
      },
      crisis: {
        type: Sequelize.STRING
      },
      gestion: {
        type: Sequelize.STRING
      },
      area: {
        type: Sequelize.STRING
      },
      mencion1: {
        type: Sequelize.STRING
      },
      mencion2: {
        type: Sequelize.STRING
      },
      mencion3: {
        type: Sequelize.STRING
      },
      mencion4: {
        type: Sequelize.STRING
      },
      mencion5: {
        type: Sequelize.STRING
      },
      status: {
        type: Sequelize.STRING
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('News');
  }
};