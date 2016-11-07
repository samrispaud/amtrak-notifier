json.extract! order, :id, :ticker, :quantity, :order_type, :status, :user_id, :created_at, :updated_at
json.url order_url(order, format: :json)