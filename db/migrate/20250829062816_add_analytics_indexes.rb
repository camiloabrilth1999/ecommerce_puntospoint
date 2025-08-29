class AddAnalyticsIndexes < ActiveRecord::Migration[7.2]
  def change
    # Índice compuesto para consultas de analytics en purchases
    # Optimiza consultas por product_id, status y purchase_date
    add_index :purchases, [ :product_id, :status, :purchase_date ],
              name: 'idx_purchases_analytics',
              comment: 'Optimiza consultas de analytics por producto, estado y fecha'

    # Índice compuesto para relación many-to-many de productos y categorías
    # Optimiza joins entre categories y products via product_categories
    add_index :product_categories, [ :category_id, :product_id ],
              name: 'idx_product_categories_analytics',
              comment: 'Optimiza joins de analytics entre categorías y productos'

    # Índice adicional para consultas de purchases por client_id y status
    add_index :purchases, [ :client_id, :status ],
              name: 'idx_purchases_client_status',
              comment: 'Optimiza filtros por cliente y estado en analytics'

    # Índice para consultas por administrator_id via products
    add_index :products, [ :administrator_id, :active ],
              name: 'idx_products_admin_active',
              comment: 'Optimiza filtros por administrador y productos activos'
  end
end
