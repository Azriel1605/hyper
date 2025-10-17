import Header from "@/components/header"
import Hero from "@/components/hero"
import PageTransition from "@/components/page-transition"

export default function HomePage() {
  return (
    <>
      <Header />
      <PageTransition>
        <Hero />
        <section className="mx-auto max-w-5xl px-4 py-10">
          <div className="grid md:grid-cols-3 gap-6">
            {[1, 2, 3].map((i) => (
              <div
                key={i}
                className="p-5 rounded-xl border bg-card shadow-sm animate-in fade-in slide-in-from-bottom-2 duration-500"
              >
                <img
                  src={`/wellness-.jpg?height=140&width=520&query=wellness%20${i}`}
                  alt="placeholder"
                  className="w-full h-36 object-cover rounded-md mb-4"
                />
                <h3 className="h-heading font-semibold text-lg">Healthy Tip {i}</h3>
                <p className="text-sm mt-1">
                  Short blurb to educate users about lifestyle choices related to blood pressure.
                </p>
              </div>
            ))}
          </div>
        </section>
      </PageTransition>
    </>
  )
}
