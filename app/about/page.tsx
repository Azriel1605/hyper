import Header from "@/components/header"
import PageTransition from "@/components/page-transition"

export default function AboutPage() {
  return (
    <>
      <Header />
      <PageTransition>
        <section className="mx-auto max-w-4xl px-4 py-10 md:py-14">
          <h1 className="h-heading text-4xl md:text-5xl font-bold">About Us</h1>
          <p className="mt-4">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer euismod, nibh a interdum vehicula, lorem
            massa dapibus arcu, sed porttitor augue arcu quis lorem. Cras non urna at elit imperdiet rhoncus. Nunc
            vulputate, nulla id dictum imperdiet, velit metus aliquam mauris, at eleifend turpis lectus sit amet metus.
          </p>
          <p className="mt-4">
            Fusce eget neque vel enim rutrum interdum. Sed dignissim, augue a aliquet efficitur, dui erat efficitur
            libero, id varius diam ligula ut ipsum. Suspendisse potenti. Donec ac leo sed urna rhoncus congue a in
            lorem.
          </p>
        </section>
      </PageTransition>
    </>
  )
}
