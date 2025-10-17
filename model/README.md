Tempatkan file model Anda di sini sebagai `model.pkl` (scikit-learn LogisticRegression/RandomForest, dsb).
Anda juga bisa set ENV `MODEL_PATH` mengarah ke file model lain.
Model idealnya mendukung `predict_proba(X)` dan menerima urutan fitur berikut:

[ "Glucose", "Sleep_Duration", "Salt_Intake", "Triglycerides", "HDL", "BMI", "Heart_Rate", "LDL", "Systolic_BP", "Smoking_Status", "Diabetes", "Physical_Activity_Level" ]
