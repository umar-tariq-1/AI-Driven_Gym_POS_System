from flask import Flask, request, jsonify
import joblib
import pandas as pd

app = Flask(__name__)

# Load the trained and saved model
try:
    print("Loading model...")
    model = joblib.load("random_forest_churn_predictor.pkl")
    print("\nModel loaded successfully.")
except Exception as e:
    print("\nFailed to load model:", str(e))
    model = None

# Define expected input schema
EXPECTED_FEATURES = {
    "gender": int,
    "Near_Location": int,
    "Partner": int,
    "Phone": int,
    "Contract_period": int,
    "Age": int,
    "Month_to_end_contract": int,
    "Avg_class_frequency_total": float,
    "Avg_class_frequency_current_month": float
}

# Input validation function
def validate_input(data):
    errors = {}
    validated = {}

    # Check for unexpected fields
    unexpected = set(data.keys()) - set(EXPECTED_FEATURES.keys())
    if unexpected:
        errors["unexpected_fields"] = f"Unexpected fields: {', '.join(unexpected)}"

    for key, expected_type in EXPECTED_FEATURES.items():
        value = data.get(key)

        if value is None or (isinstance(value, str) and value.strip() == ""):
            errors[key] = "Missing or empty"
            continue

        try:
            validated[key] = expected_type(value)
        except (ValueError, TypeError):
            errors[key] = f"Expected {expected_type.__name__}, got {type(value).__name__}"

    return validated, errors

# Prediction route
@app.route('/predict', methods=['POST'])
def predict():
    if model is None:
        return jsonify({"error": "Model not loaded"}), 500

    data = request.get_json()
    if not data:
        return jsonify({"error": "No JSON body found"}), 400

    validated_data, errors = validate_input(data)
    if errors:
        return jsonify({"error": "Invalid input", "details": errors}), 400

    input_df = pd.DataFrame([validated_data])
    prediction = model.predict(input_df)
    return jsonify({"prediction": int(prediction[0])})  # Cast to int to ensure JSON serializability

if __name__ == '__main__':
    app.run(debug=True)
