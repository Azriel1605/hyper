import Header from "@/components/header"
import PageTransition from "@/components/page-transition"

export default function HypertensionPage() {
  return (
    <>
      <Header />
      <PageTransition>
        <section className="bg-secondary">
          <div className="mx-auto max-w-5xl px-4 py-10 md:py-14">
            <h1 className="h-heading text-4xl md:text-6xl font-bold text-balance">Hypertension</h1>
            <p className="mt-4 max-w-3xl text-pretty md:text-lg">
              Hypertension, also known as high or raised blood pressure, is a condition where the blood vessels
              consistently have elevated pressure (140/90 mmHg or higher). Classification of office BP and definitions
              of hypertension grades (2023 ESH).
            </p>

            <div className="mt-8 rounded-xl border bg-card shadow-sm overflow-hidden">
              <div className="px-4 py-3 font-semibold bg-secondary/60">Classification Table</div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm md:text-base">
                  <thead>
                    <tr className="bg-card border-t">
                      <th className="text-left p-3">Category</th>
                      <th className="text-left p-3">Systolic (mmHg)</th>
                      <th className="text-left p-3">Diastolic (mmHg)</th>
                    </tr>
                  </thead>
                  <tbody>
                    {[
                      ["Optimal", "<120", "<80"],
                      ["Normal", "120–129", "80–84"],
                      ["High-normal", "130–139", "85–89"],
                      ["Grade 1 hypertension", "140–159", "90–99"],
                      ["Grade 2 hypertension", "160–179", "100–109"],
                      ["Grade 3 hypertension", "≥180", "≥110"],
                      ["Isolated systolic hypertension", "≥140", "<90"],
                      ["Isolated diastolic hypertension", "<140", "≥90"],
                    ].map((r) => (
                      <tr key={r[0]} className="border-t">
                        <td className="p-3 font-medium">{r[0]}</td>
                        <td className="p-3">{r[1]}</td>
                        <td className="p-3">{r[2]}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </section>
      </PageTransition>
    </>
  )
}
