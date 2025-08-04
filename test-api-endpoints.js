const fetch = require('node-fetch');

const BASE_URL = 'http://localhost:3000/api';

async function testAPIEndpoints() {
  try {
    console.log('🌐 Probando endpoints de la API de menciones...\n');
    
    // 1. Probar GET /api/mentions/active
    console.log('📡 GET /api/mentions/active');
    try {
      const response = await fetch(`${BASE_URL}/mentions/active`);
      const data = await response.json();
      console.log('   Status:', response.status);
      console.log('   Response:', JSON.stringify(data, null, 2));
    } catch (error) {
      console.log('   ❌ Error:', error.message);
    }
    console.log('');
    
    // 2. Probar PUT /api/mentions/active
    console.log('📡 PUT /api/mentions/active');
    try {
      const newMentions = [
        { position: 1, name: 'Ana Martínez' },
        { position: 2, name: 'Roberto Silva' },
        { position: 3, name: 'Laura Fernández' },
        { position: 4, name: 'Miguel Torres' }
      ];
      
      const response = await fetch(`${BASE_URL}/mentions/active`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ mentions: newMentions })
      });
      
      const data = await response.json();
      console.log('   Status:', response.status);
      console.log('   Response:', JSON.stringify(data, null, 2));
    } catch (error) {
      console.log('   ❌ Error:', error.message);
    }
    console.log('');
    
    // 3. Verificar que se actualizó
    console.log('📡 GET /api/mentions/active (después de actualizar)');
    try {
      const response = await fetch(`${BASE_URL}/mentions/active`);
      const data = await response.json();
      console.log('   Status:', response.status);
      console.log('   Response:', JSON.stringify(data, null, 2));
    } catch (error) {
      console.log('   ❌ Error:', error.message);
    }
    
    console.log('\n✅ Prueba de endpoints completada');
    
  } catch (error) {
    console.error('❌ Error general:', error.message);
  }
}

testAPIEndpoints(); 