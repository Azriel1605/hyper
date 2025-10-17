import Link from "next/link"

export default function Hero() {
  return (
    <section className="relative overflow-hidden bg-secondary">
      <div className="mx-auto max-w-5xl px-4 py-10 md:py-16 grid md:grid-cols-2 gap-8 items-center">
        <div>
          <h1 className="h-heading text-4xl md:text-6xl font-bold text-balance text-primary">What’s your HDSC?</h1>
          <p className="mt-4 text-base md:text-lg text-pretty">
            Hypertension Disease Stage Character (HDSC) is a lifestyle-based test designed to prevent hypertension.
          </p>
          <div className="mt-6 flex gap-3">
            <Link href="#" className="px-4 py-2 rounded-md border">
              About Character
            </Link>
            <Link href="/hdsc-test" className="px-4 py-2 rounded-md bg-primary text-primary-foreground shadow">
              Take the Test →
            </Link>
          </div>
        </div>
        <div className="relative">
          {/* Placeholder image per instruksi */}
          <img
            src="/health-illustration.jpg"
            alt="Health illustration placeholder"
            className="w-full h-auto rounded-lg shadow-md float"
          />
          {/* dekorasi titik */}
          <div className="absolute -top-3 -left-3 h-3 w-3 rounded-full bg-primary/70 float" />
          <div
            className="absolute -bottom-3 -right-3 h-3 w-3 rounded-full bg-primary/70 float"
            style={{ animationDelay: "1s" }}
          />
        </div>
      </div>
    </section>
  )
}
