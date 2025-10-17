from __future__ import annotations

import os
import math
import pickle
from typing import Any, Dict

import numpy as np
from flask import Flask, render_template, request, redirect, url_for, flash
import pandas as pd

try:
    import joblib  # type: ignore
except Exception:
    joblib = None  # joblib opsional, fallback ke pickle

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "dev-secret")  # untuk flash message

MODEL_PATH = os.getenv("MODEL_PATH", "model/model.pkl")


def load_model():
    if os.path.exists(MODEL_PATH):
        try:
            if joblib:
                return joblib.load(MODEL_PATH)
            with open(MODEL_PATH, "rb") as f:
                return pickle.load(f)
        except Exception as e:
            print(f"[v0] Gagal memuat model: {e}")
            return None
    return None


model = load_model()


def map_inputs(form: Dict[str, Any]) -> Dict[str, Any]:
    # Ambil dan konversi nilai dari form; gunakan None untuk nilai kosong
    def to_float(name: str):
        val = form.get(name, "").strip()
        return float(val) if val not in ("", None) else None

    smoking_map = {"never": 0, "former": 1, "smoking": 2}
    diabetes_map = {"no": 0, "yes": 1}
    activity_map = {"low": 0, "moderate": 1, "high": 2}

    return {
        "Glucose": to_float("Glucose"),
        "Sleep_Duration": to_float("Sleep_Duration"),
        "Salt_Intake": to_float("Salt_Intake"),
        "Triglycerides": to_float("Triglycerides"),
        "HDL": to_float("HDL"),
        "BMI": to_float("BMI"),
        "Heart_Rate": to_float("Heart_Rate"),
        "LDL": to_float("LDL"),
        "Systolic_BP": to_float("Systolic_BP"),
        "Smoking_Status": smoking_map.get(form.get("Smoking_Status", "never"), 0),
        "Diabetes": diabetes_map.get(form.get("Diabetes", "no"), 0),
        "Physical_Activity_Level": activity_map.get(form.get("Physical_Activity_Level", "moderate"), 1),
        "Dump1":0,
        "Dump2":0,
        "Dump3":0,
        "Dump4":0,
        "Dump5":0,
        "Dump6":0,
        "Dump7":0,
        "Dump8":0,
        "Dump9":0,
        "Dump10":0,
    }


def validate_required(mapped: Dict[str, Any]) -> str | None:
    # Pastikan semua numeric tidak None
    numeric_fields = [
        "Glucose", "Sleep_Duration", "Salt_Intake", "Triglycerides", "HDL",
        "BMI", "Heart_Rate", "LDL", "Systolic_BP"
    ]
    missing = [f for f in numeric_fields if mapped.get(f) is None]
    if missing:
        return f"Field berikut wajib diisi: {', '.join(missing)}"
    return None


def to_feature_vector(mapped: Dict[str, Any]) -> pd.DataFrame:
    # Urutan sesuai permintaan pengguna
    order = [
        "Glucose",
        "Sleep_Duration",
        "Salt_Intake",
        "Triglycerides",
        "HDL",
        "BMI",
        "Heart_Rate",
        "LDL",
        "Systolic_BP",
        "Smoking_Status",
        "Diabetes",
        "Physical_Activity_Level",
        "Dump1",
        "Dump2",
        "Dump3",
        "Dump4",
        "Dump5",
        "Dump6",
        "Dump7",
        "Dump8",
        "Dump9",
        "Dump10",
    ]
    # Buat dataframe dengan satu baris
    df = pd.DataFrame([{k: float(mapped[k]) for k in order}], columns=order)
    return df


def fallback_probability(x: np.ndarray) -> float:
    # Heuristik ringan berbasis domain agar tidak random:
    # koefisien kasar untuk menaikkan/menurunkan risiko
    print(x[0])
    glucose, sleep, salt, trig, hdl, bmi, hr, ldl, sys_bp, smoking, diab, act, dump0, dump1, dump2, dump3, dump4, dump5, dump6, dump7, dump8, dump9  = x[0]
    z = 0.0
    z += 0.006 * (sys_bp - 120.0)
    z += 0.004 * (ldl - 100.0)
    z += 0.003 * (trig - 150.0)
    z += 0.004 * (glucose - 100.0)
    z += 0.018 * diab
    z += 0.012 * smoking
    z += 0.010 * (bmi - 25.0)
    z -= 0.006 * (hdl - 50.0)
    z -= 0.004 * (sleep - 7.0)
    z -= 0.004 * act
    # Sigmoid
    p = 1.0 / (1.0 + math.exp(-z))
    # clamp untuk berjaga-jaga
    return float(max(0.0, min(1.0, p)))


@app.route("/")
def home():
    return render_template("index.html")

@app.route("/hypertension")
def hypertension():
    return render_template("hypertension.html")

@app.route("/application")
def application():
    return render_template("application.html")

@app.route("/about")
def about():
    return render_template("about.html")

@app.route("/test")
def test():
    return render_template("test.html")


@app.route("/predict", methods=["POST"])
def predict():
    mapped = map_inputs(request.form)
    err = validate_required(mapped)
    if err:
        flash(err, "error")
        return redirect(url_for("test"))

    x = to_feature_vector(mapped)

    try:
        if model is not None and hasattr(model, "predict_proba"):
            print("first")
            proba = float(model.predict_proba(x)[:, 1])
        elif model is not None and hasattr(model, "predict"):
            print("second")
            # gunakan predict jika hanya tersedia, map ke 0/1 dengan probabilitas default
            pred = float(model.predict(x)[0])
            proba = 0.8 if pred >= 0.5 else 0.2
            print("not using proba")
        else:
            print("third") 
            proba = fallback_probability(x)
    except Exception as e:
        print(f"[v0] Error saat inferensi: {e}")
        proba = fallback_probability(x)

    percent = int(round(proba * 100))
    return render_template("result.html", percent=percent, inputs=mapped)


if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    debug = os.getenv("FLASK_ENV", "development") == "development"
    app.run(host="0.0.0.0", port=port, debug=debug)
