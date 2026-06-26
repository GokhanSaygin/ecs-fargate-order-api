from flask import Flask, jsonify

app = Flask(__name__)

orders = [
    {
        "id": 1,
        "customer": "John Smith",
        "item": "Laptop",
        "quantity": 1,
        "status": "processing"
    },
    {
        "id": 2,
        "customer": "Sarah Johnson",
        "item": "Wireless Mouse",
        "quantity": 2,
        "status": "shipped"
    },
    {
        "id": 3,
        "customer": "Michael Brown",
        "item": "Keyboard",
        "quantity": 1,
        "status": "delivered"
    }
]

@app.route("/")
def home():
    return jsonify({
        "message": "ECS Fargate Order API is running with CI/CD",
        "project": "ECS Fargate Order Microservice",
        "status": "success"
    })

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    })

@app.route("/orders")
def get_orders():
    return jsonify({
        "orders": orders
    })

@app.route("/orders/<int:order_id>")
def get_order(order_id):
    for order in orders:
        if order["id"] == order_id:
            return jsonify(order)

    return jsonify({
        "error": "Order not found"
    }), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)