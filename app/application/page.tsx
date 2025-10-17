import Header from "@/components/header"
import PageTransition from "@/components/page-transition"

export default function ApplicationPage() {
  return (
    <>
      <Header />
      <PageTransition>
        <section className="mx-auto max-w-5xl px-4 py-10 md:py-14">
          <h1 className="h-heading text-4xl md:text-6xl font-bold text-balance">Application</h1>
          <p className="mt-4 max-w-3xl md:text-lg">
            To help maintain good blood pressure along with a healthy lifestyle, download our companion app from your
            favorite store. Play simple daily challenges, track habits, and redeem rewards inside the app.
          </p>
          <h2 className="h-heading mt-8 text-2xl md:text-3xl font-semibold text-center">Download now!</h2>
          <div className="mt-6 flex flex-col sm:flex-row items-center justify-center gap-4">
            <img src="/app-store-badge.png" alt="App Store badge placeholder" className="h-16 w-auto" />
            <img src="/google-play-badge.png" alt="Google Play badge placeholder" className="h-16 w-auto" />
          </div>
        </section>
      </PageTransition>
    </>
  )
}
