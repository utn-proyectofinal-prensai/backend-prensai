class CreateNews < ActiveRecord::Migration[8.0]
  def change
    create_table :news do |t|
      t.string :titulo
      t.string :tipo_publicacion
      t.string :fecha
      t.string :soporte
      t.string :medio
      t.string :seccion
      t.string :autor
      t.string :conductor
      t.string :entrevistado
      t.string :tema
      t.string :etiqueta1
      t.string :etiqueta2
      t.string :link
      t.string :alcance
      t.string :cotizacion
      t.string :tapa
      t.string :valoracion
      t.string :eje_comunicacional
      t.string :factor_politico
      t.string :crisis
      t.string :gestion
      t.string :area
      t.string :mencion1
      t.string :mencion2
      t.string :mencion3
      t.string :mencion4
      t.string :mencion5

      t.timestamps
    end
  end
end
