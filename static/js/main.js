document.addEventListener("DOMContentLoaded", () => {
  // Intersection Observer untuk animasi saat elemen masuk viewport
  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -50px 0px",
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("animate-fade-in")
        observer.unobserve(entry.target)
      }
    })
  }, observerOptions)

  // Observe semua elemen dengan class animate-on-scroll
  document.querySelectorAll(".animate-on-scroll").forEach((el) => {
    observer.observe(el)
  })

  // Animasi row form dengan stagger
  const rows = document.querySelectorAll(".score-card .row")
  rows.forEach((row, index) => {
    row.style.animationDelay = `${index * 0.05}s`
  })

  // Animasi kv-key dan kv-val dengan stagger
  const kvItems = document.querySelectorAll(".kv-key, .kv-val")
  kvItems.forEach((item, index) => {
    item.style.animationDelay = `${index * 0.08}s`
  })

  // Form submit animation
  const form = document.querySelector("form")
  if (form) {
    form.addEventListener("submit", (e) => {
      const btn = form.querySelector("button[type='submit']")
      if (btn) {
        btn.classList.add("animate-pulse")
      }
    })
  }

  // Smooth scroll untuk anchor links
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", function (e) {
      const href = this.getAttribute("href")
      if (href !== "#") {
        e.preventDefault()
        const target = document.querySelector(href)
        if (target) {
          target.scrollIntoView({
            behavior: "smooth",
            block: "start",
          })
        }
      }
    })
  })
})
