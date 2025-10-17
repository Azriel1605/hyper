import Header from "@/components/header"
import PageTransition from "@/components/page-transition"

export default function ResultPage({ searchParams }: { searchParams: { risk?: string } }) {
  const risk = Math.max(0, Math.min(100, Number(searchParams?.risk ?? 0)))
  let category: "low" | "medium" | "high" = "low"
  if (risk >= 70) category = "high"
  else if (risk >= 40) category = "medium"

  const view = {
    low: {
      name: "Joypal",
      image: "/happy-cute-character.jpg",
      description:
        "Joypal is very happy, loves exercising, and enjoys eating healthy food. Keep up the fantastic lifestyle to stay in great shape and continue enjoying good health.",
    },
    medium: {
      name: "Balancer",
      image: "/balanced-cute-character.jpg",
      description:
        "Balancer is doing okay but could improve. Try maintaining regular physical activity, lower salt intake, and monitor blood pressure routinely.",
    },
    high: {
      name: "Guardian",
      image: "/strong-cute-character.jpg",
      description:
        "Guardian signals elevated risk. Consider consulting a healthcare provider, adopt a low-salt diet, and increase consistent activity to reduce risk.",
    },
  } as const

  const model = view[category]

  return (
    <>
      <Header />
      <PageTransition>
        <section className="mx-auto max-w-5xl px-4 py-10">
          <div className="grid md:grid-cols-2 gap-8 items-center">
            <div className="order-2 md:order-1">
              <h1 className="h-heading text-3xl md:text-5xl font-bold">Your HDSC Result</h1>
              <p className="mt-3">Perkiraan kemungkinan hipertensi berdasarkan input Anda.</p>
              <div className="mt-6 flex items-center gap-6">
                <div className="relative size-36 md:size-44 radial" style={{ ["--val" as any]: risk }}>
                  <div className="absolute inset-2 rounded-full bg-card border flex flex-col items-center justify-center">
                    <span className="h-heading text-3xl md:text-4xl font-bold">{risk}%</span>
                    <span className="text-xs mt-1 uppercase tracking-wide">{category}</span>
                  </div>
                </div>
                <ul className="space-y-2 text-sm">
                  <li>• Low: 0–39%</li>
                  <li>• Medium: 40–69%</li>
                  <li>• High: 70–100%</li>
                </ul>
              </div>

              <div className="mt-8">
                <h2 className="h-heading text-2xl md:text-3xl font-bold">{model.name}</h2>
                <p className="mt-2 md:text-lg text-pretty">{model.description}</p>
              </div>

              <div className="mt-6 flex gap-3">
                <a href="/hdsc-test" className="px-4 py-2 rounded-md border">
                  Edit Inputs
                </a>
                <a href="/" className="px-4 py-2 rounded-md bg-primary text-primary-foreground">
                  Back Home
                </a>
              </div>
            </div>

            <div className="order-1 md:order-2">
              <img
                src={model.image || "/placeholder.svg"}
                alt={`${model.name} placeholder`}
                className="w-full h-auto rounded-xl shadow-md animate-in zoom-in-50 duration-500"
              />
            </div>
          </div>
        </section>
      </PageTransition>
    </>
  )
}
