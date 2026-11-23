from flask_sqlalchemy import SQLAlchemy
import numpy as np
from sklearn.linear_model import LinearRegression

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(100))
    last_name = db.Column(db.String(100))
    email = db.Column(db.String(100), unique=True)
    password = db.Column(db.String(255))

class GlucoseModel:
    def __init__(self):
        self.model = LinearRegression()
        self._train()

    def _train(self):
        np.random.seed(42)

        data = []

        for _ in range(200):  # more data = better model
            carbs = np.random.uniform(0, 150)        # grams
            insulin = np.random.uniform(0, 10)       # units

            # realistic formula
            glucose = (
                80                                  # baseline
                + carbs * 0.8                       # carbs increase glucose
                - insulin * 10                      # insulin decreases glucose
                + np.random.normal(0, 10)           # biological noise
            )

            data.append([carbs, insulin, glucose])

        data = np.array(data)

        X = data[:, :2]
        y = data[:, 2]

        self.model.fit(X, y)

    def predict(self, carbs, insulin):
        return self.model.predict([[carbs, insulin]])[0]
    
class GlucoseEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_email = db.Column(db.String(100))
    carbs = db.Column(db.Float)
    insulin_dose = db.Column(db.Float)
    prediction = db.Column(db.Float)
    time = db.Column(db.String(100))
    risk_level = db.Column(db.String(50))
    advice = db.Column(db.String(255))