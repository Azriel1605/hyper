import { NextResponse } from "next/server"

export async function POST(req: Request) {
  const body = await req.json().catch(() => ({}))
  const {
    Glucose = 90,
    Sleep_Duration = 7,
    Salt_Intake = 5,
    Triglycerides = 130,
    HDL = 50,
    BMI = 23,
    Heart_Rate = 72,
    LDL = 110,
    Systolic_BP = 120,
    Smoking_Status = "Never",
    Diabetes = "No",
    Physical_Activity_Level = "Medium",
  } = body || {}

  // Simple placeholder scoring; replace with your ML inference
  let score =
    0.25 * Math.max(0, (Systolic_BP - 110) / 50) * 100 +
    0.15 * Math.max(0, (BMI - 22) / 10) * 100 +
    0.12 * Math.max(0, (LDL - 100) / 80) * 100 +
    0.1 * Math.max(0, (Triglycerides - 120) / 200) * 100 +
    0.08 * Math.max(0, (Glucose - 90) / 60) * 100 +
    0.05 * Math.max(0, (70 - HDL) / 40) * 100

  if (Smoking_Status === "Current") score += 10
  else if (Smoking_Status === "Former") score += 4

  if (Diabetes === "Yes") score += 12

  if (Physical_Activity_Level === "Low") score += 8
  else if (Physical_Activity_Level === "High") score -= 5

  if (Sleep_Duration < 6) score += 6
  if (Salt_Intake > 6) score += 6
  if (Heart_Rate > 90) score += 4

  score = Math.max(0, Math.min(100, Math.round(score)))

  return NextResponse.json({ risk: score })
}
