import Header from "@/components/header"
import PageTransition from "@/components/page-transition"
import TestForm from "@/components/test-form"

export default function HDSCTestPage() {
  return (
    <>
      <Header />
      <PageTransition>
        <section className="bg-secondary">
          <div className="mx-auto max-w-5xl px-4 py-6 md:py-10">
            <div className="flex items-center gap-3 mb-4">
              <img src="/abstract-logo.png" alt="" className="h-10 w-10 rounded-md" />
              <h2 className="h-heading text-2xl md:text-4xl font-bold">Free Lifestyle Scoring Test</h2>
            </div>
            <p className="text-sm md:text-base mb-6">
              Isi semua kolom berikut dengan benar. Hasil akan menampilkan persentase kemungkinan hipertensi.
            </p>
            <TestForm />
          </div>
        </section>
      </PageTransition>
    </>
  )
}
