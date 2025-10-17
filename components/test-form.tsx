"use client"
import { useState } from "react"
import type React from "react"

import { useRouter } from "next/navigation"
import { motion } from "framer-motion"

type Payload = {
  Glucose: number
  Sleep_Duration: number
  Salt_Intake: number
  Triglycerides: number
  HDL: number
  BMI: number
  Heart_Rate: number
  LDL: number
  Systolic_BP: number
  Smoking_Status: "Never" | "Former" | "Current"
  Diabetes: "No" | "Yes"
  Physical_Activity_Level: "Low" | "Medium" | "High"
}

const defaultValues: Payload = {
  Glucose: 90,
  Sleep_Duration: 7,
  Salt_Intake: 5,
  Triglycerides: 130,
  HDL: 50,
  BMI: 23,
  Heart_Rate: 72,
  LDL: 110,
  Systolic_BP: 120,
  Smoking_Status: "Never",
  Diabetes: "No",
  Physical_Activity_Level: "Medium",
}

export default function TestForm() {
  const [form, setForm] = useState<Payload>(defaultValues)
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const update = (k: keyof Payload, v: string) => {
    // numbers or enums
    const numKeys: (keyof Payload)[] = [
      "Glucose",
      "Sleep_Duration",
      "Salt_Intake",
      "Triglycerides",
      "HDL",
      "BMI",
      "Heart_Rate",
      "LDL",
      "Systolic_BP",
    ]
    // @ts-ignore
    setForm((prev) => ({ ...prev, [k]: numKeys.includes(k) ? Number(v) : v }))
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    const res = await fetch("/api/predict", { method: "POST", body: JSON.stringify(form) })
    const data = await res.json().catch(() => ({ risk: 0 }))
    setLoading(false)
    router.push(`/result?risk=${encodeURIComponent(data.risk ?? 0)}`)
  }

  return (
    <motion.form
      onSubmit={onSubmit}
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.35 }}
      className="space-y-4"
    >
      <div className="rounded-xl border shadow-sm overflow-hidden">
        <div className="bg-primary text-primary-foreground px-4 py-3 h-heading text-xl md:text-2xl font-bold text-center">
          Free Lifestyle Scoring Test
        </div>

        <div className="p-3 md:p-4">
          <div className="table-like">
            {/* Baris dibuat 3 kolom di md+, 2 kolom di mobile untuk kesesuaian mockup */}
            {[
              ["Glucose", "mg/dL"],
              ["Sleep_Duration", "hours"],
              ["Salt_Intake", "g/day"],
              ["Triglycerides", "mg/dL"],
              ["HDL", "mg/dL"],
              ["BMI", "kg/m²"],
              ["Heart_Rate", "bpm"],
              ["LDL", "mg/dL"],
              ["Systolic_BP", "mmHg"],
            ].map(([label, unit]) => (
              <div key={label} className="table-like-row grid-cols-2 md:grid-cols-3">
                <div className="test-label">{label}</div>
                <div className="test-cell">
                  <input
                    type="number"
                    className="w-full rounded-md border px-3 py-2"
                    value={(form as any)[label]}
                    onChange={(e) => update(label as keyof Payload, e.target.value)}
                    required
                  />
                </div>
                <div className="test-cell hidden md:block text-right text-muted-foreground">{unit}</div>
              </div>
            ))}

            <div className="table-like-row grid-cols-2 md:grid-cols-3">
              <div className="test-label">Smoking_Status</div>
              <div className="test-cell">
                <select
                  className="w-full rounded-md border px-3 py-2"
                  value={form.Smoking_Status}
                  onChange={(e) => update("Smoking_Status", e.target.value)}
                >
                  <option value="Never">Never smoked</option>
                  <option value="Former">Former</option>
                  <option value="Current">Current</option>
                </select>
              </div>
              <div className="test-cell hidden md:block"></div>
            </div>

            <div className="table-like-row grid-cols-2 md:grid-cols-3">
              <div className="test-label">Diabetes</div>
              <div className="test-cell">
                <select
                  className="w-full rounded-md border px-3 py-2"
                  value={form.Diabetes}
                  onChange={(e) => update("Diabetes", e.target.value)}
                >
                  <option value="No">No</option>
                  <option value="Yes">Yes</option>
                </select>
              </div>
              <div className="test-cell hidden md:block"></div>
            </div>

            <div className="table-like-row grid-cols-2 md:grid-cols-3">
              <div className="test-label">Physical_Activity_Level</div>
              <div className="test-cell">
                <select
                  className="w-full rounded-md border px-3 py-2"
                  value={form.Physical_Activity_Level}
                  onChange={(e) => update("Physical_Activity_Level", e.target.value)}
                >
                  <option value="Low">Low</option>
                  <option value="Medium">Medium</option>
                  <option value="High">High</option>
                </select>
              </div>
              <div className="test-cell hidden md:block"></div>
            </div>
          </div>

          <div className="mt-4 flex items-center justify-end gap-3">
            <button type="reset" onClick={() => setForm(defaultValues)} className="px-4 py-2 rounded-md border">
              Reset
            </button>
            <motion.button
              whileTap={{ scale: 0.98 }}
              type="submit"
              disabled={loading}
              className="px-4 py-2 rounded-md bg-primary text-primary-foreground shadow"
            >
              {loading ? "Analyzing..." : "Analyze →"}
            </motion.button>
          </div>
        </div>
      </div>
    </motion.form>
  )
}
