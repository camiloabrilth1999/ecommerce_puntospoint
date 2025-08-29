class AddGranularityAnalyticsIndex < ActiveRecord::Migration[7.2]
  def change
    # Índice específico para API 4 - consultas de granularidad optimizadas
    # Optimiza DATE_TRUNC queries por fecha, estado y filtros adicionales
    add_index :purchases, [ :status, :purchase_date ],
              name: 'idx_purchases_granularity',
              comment: 'Optimiza consultas DATE_TRUNC para analytics de granularidad'

    # Índice adicional para mejorar ORDER BY en consultas de granularidad
    add_index :purchases, [ :purchase_date, :status ],
              name: 'idx_purchases_date_status',
              comment: 'Optimiza ORDER BY purchase_date en consultas de granularidad'
  end
end
