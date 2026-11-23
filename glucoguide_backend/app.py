from datetime import datetime, timedelta
import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import check_password_hash, generate_password_hash
from models import GlucoseEntry, db, User, GlucoseModel

app = Flask(__name__)
CORS(app)

basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'users.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)

model = GlucoseModel()


def classify_glucose(value):
    if value < 70:
        return "LOW", "Your glucose is low. Consider eating fast-acting carbs."
    if value <= 140:
        return "NORMAL", "Your glucose level is normal. Keep maintaining your balance."
    return "HIGH", "High glucose detected. Consider reducing carbs or adjusting insulin."


def seed_demo_data():
    demo_email = "demo@glucoguide.tn"
    if User.query.filter_by(email=demo_email).first():
        return

    demo_user = User(
        first_name="Nermine",
        last_name="Boutabba",
        email=demo_email,
        password=generate_password_hash("Demo1234!"),
    )
    db.session.add(demo_user)

    samples = [
        (45.0, 2.5, -6),
        (60.0, 3.0, -5),
        (30.0, 4.5, -4),
        (95.0, 1.5, -3),
        (55.0, 3.5, -2),
        (40.0, 3.0, -1),
        (62.0, 3.2, 0),
    ]
    now = datetime.now()
    for carbs, insulin, day_offset in samples:
        pred = round(float(80 + carbs * 0.8 - insulin * 10), 1)
        risk, advice = classify_glucose(pred)
        ts = (now + timedelta(days=day_offset)).replace(hour=9 + (abs(day_offset) % 10), minute=15)
        db.session.add(
            GlucoseEntry(
                user_email=demo_email,
                carbs=carbs,
                insulin_dose=insulin,
                prediction=pred,
                risk_level=risk,
                advice=advice,
                time=ts.isoformat(),
            )
        )
    db.session.commit()


with app.app_context():
    db.create_all()
    seed_demo_data()


@app.route('/register', methods=['POST'])
def register():
    data = request.json or {}
    if data.get('password') != data.get('confirm_password'):
        return {"error": "Passwords do not match"}, 400

    if User.query.filter_by(email=data.get('email')).first():
        return {"error": "User already exists"}, 400

    new_user = User(
        first_name=data.get('first_name', ''),
        last_name=data.get('last_name', ''),
        email=data.get('email', ''),
        password=generate_password_hash(data.get('password', '')),
    )
    db.session.add(new_user)
    db.session.commit()
    return {"message": "User created successfully"}


@app.route('/login', methods=['POST'])
def login():
    data = request.json or {}
    user = User.query.filter_by(email=data.get('email')).first()
    raw_password = data.get('password', '')
    valid = user is not None and (
        check_password_hash(user.password, raw_password) or user.password == raw_password
    )
    if not valid:
        return {"error": "Invalid credentials"}, 401

    return {
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "token": "glucoguide-session-token",
    }


@app.route('/predict', methods=['POST'])
def predict():
    data = request.json or {}
    carbs = float(data.get('carbs', 0))
    insulin = float(data.get('insulinDose', 0))
    prediction = model.predict(carbs, insulin)
    return jsonify({"prediction": round(float(prediction), 2)})


@app.route('/add_entry', methods=['POST'])
def add_entry():
    data = request.json or {}
    entry = GlucoseEntry(
        user_email=data['email'],
        carbs=data['carbs'],
        insulin_dose=data['insulinDose'],
        prediction=data['prediction'],
        risk_level=data['riskLevel'],
        advice=data['advice'],
        time=data['time'],
    )
    db.session.add(entry)
    db.session.commit()
    return {"message": "Entry saved"}


@app.route('/history/<email>', methods=['GET'])
def get_history(email):
    entries = GlucoseEntry.query.filter_by(user_email=email).all()
    return [
        {
            "carbs": e.carbs,
            "insulinDose": e.insulin_dose,
            "prediction": e.prediction,
            "riskLevel": e.risk_level,
            "advice": e.advice,
            "time": e.time,
        }
        for e in entries
    ]


@app.route('/')
def home():
    return {"status": "Glucoguide API running"}


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
