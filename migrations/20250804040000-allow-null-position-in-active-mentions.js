'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.changeColumn('ActiveMentions', 'position', {
      type: Sequelize.INTEGER,
      allowNull: true,
      validate: {
        min: 1,
        max: 5
      }
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.changeColumn('ActiveMentions', 'position', {
      type: Sequelize.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 5
      }
    });
  }
}; 